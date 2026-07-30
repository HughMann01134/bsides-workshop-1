#!/bin/bash
# Provisions the vulnerable WordPress target for Workshop 1.
# Runs once via the wp-cli service, against the shared wp_data volume.
set -euo pipefail

cd /var/www/html

echo "[*] Waiting for WordPress core files to exist..."
until [ -f wp-load.php ]; do
  sleep 2
done

echo "[*] Waiting for database to accept connections..."
until wp db check --path=/var/www/html --allow-root 2>/dev/null; do
  sleep 3
done

# Internal address only — this is what the attacker script, benign traffic
# simulator, and Suricata/Zeek will all see. Port 8080 is a host-only mapping
# for convenient browser access from outside the VM; WordPress must NOT think
# that's its canonical URL, or every internal request gets a 301 redirect
# (which will corrupt exploit timing and log shapes later).
INTERNAL_URL="http://172.28.0.10"

if wp core is-installed --allow-root 2>/dev/null; then
  echo "[*] WordPress already installed, skipping core install."
  echo "[*] Ensuring siteurl/home are set to the internal address..."
  wp option update siteurl "${INTERNAL_URL}" --allow-root
  wp option update home "${INTERNAL_URL}" --allow-root
else
  echo "[*] Installing WordPress core (5.4)..."
  wp core install \
    --url="${INTERNAL_URL}" \
    --title="Prairie Wares Co." \
    --admin_user=admin \
    --admin_password="Welcome2024!" \
    --admin_email="admin@prairiewares.example" \
    --skip-email \
    --allow-root
fi

echo "[*] Installing wpDiscuz 7.0.4 (CVE-2020-24186 target)..."
if ! wp plugin is-installed wpdiscuz --allow-root 2>/dev/null; then
  # Try the official install path first, pinned to the vulnerable version.
  if ! wp plugin install wpdiscuz --version=7.0.4 --allow-root 2>/dev/null; then
    echo "[!] wp plugin install by version failed, falling back to local zip."
    wp plugin install /tmp/wpdiscuz-7.0.4.zip --allow-root
  fi
fi
# --user=admin matters here: wpDiscuz's activation routine does its own
# current_user_can() check rather than relying on WP-CLI's internal bypass.
# Without an explicit user context, WP-CLI has no logged-in user, the
# capability check fails, and wpDiscuz wp_die()s with its own hardcoded
# "Permission Denied !!!" message instead of a normal WP-CLI error.
wp plugin activate wpdiscuz --allow-root --user=admin

echo "[*] Setting pretty permalinks (required for REST API pretty-paths)..."
wp rewrite structure '/%postname%/' --allow-root
wp rewrite flush --hard --allow-root

echo "[*] Enabling wpDiscuz file uploads (wmuIsEnabled)..."
wp db query \
  "INSERT INTO wp_options (option_name, option_value, autoload)
   VALUES ('wpdiscuz_options', 'a:1:{s:7:\"content\";a:1:{s:12:\"wmuIsEnabled\";i:1;}}', 'yes')
   ON DUPLICATE KEY UPDATE
   option_value = 'a:1:{s:7:\"content\";a:1:{s:12:\"wmuIsEnabled\";i:1;}}';" \
  --allow-root

echo "[*] Creating sample post if not already present..."
if ! wp post list --post_status=publish --fields=post_title --format=csv --allow-root 2>/dev/null | grep -q "Welcome to Prairie Wares"; then
  wp post create --allow-root \
    --post_type=post \
    --post_status=publish \
    --post_title="Welcome to Prairie Wares" \
    --post_content="We sell handmade prairie goods. Come see our new fall lineup."
fi

curl -s -o /dev/null -w "wpDiscuz upload nonce present: " \
  "${INTERNAL_URL}/hello-world/"
curl -s "${INTERNAL_URL}/hello-world/" | grep -c "wmuSecurity" | \
  xargs -I{} bash -c '[ "{}" -gt "0" ] && echo "YES" || echo "NO"'

echo "[*] Provisioning complete."
echo "    Internal URL (attacker script, sensors, benign traffic): ${INTERNAL_URL}"
echo "    Host browser access:                                    http://localhost:8080"
echo "    Admin: admin / Welcome2024!"
echo "    Note:  This password is intentionally weak. It is the target of"
echo "           the T1110.001 brute-force step. Do not reuse it anywhere real."
echo "    Note:  Host browser access via :8080 will 301-redirect to the"
echo "           internal URL — that's expected, browsers follow it fine."
