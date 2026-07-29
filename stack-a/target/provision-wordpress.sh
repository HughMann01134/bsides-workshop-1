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

if wp core is-installed --allow-root 2>/dev/null; then
  echo "[*] WordPress already installed, skipping core install."
else
  echo "[*] Installing WordPress core (5.4)..."
  wp core install \
    --url="http://172.28.0.10:8080" \
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
wp plugin activate wpdiscuz --allow-root

echo "[*] Setting a couple of benign posts for realistic traffic noise..."
wp post create --allow-root \
  --post_type=post \
  --post_status=publish \
  --post_title="Welcome to Prairie Wares" \
  --post_content="We sell handmade prairie goods. Come see our new fall lineup." \
  2>/dev/null || true

echo "[*] Verifying wpDiscuz upload endpoint responds..."
curl -s -o /dev/null -w "wp-json/wpdiscuz endpoint HTTP status: %{http_code}\n" \
  "http://172.28.0.10:8080/wp-json/wpdiscuz/v1/uploadFile" || true

echo "[*] Provisioning complete."
echo "    URL:   http://localhost:8080  (or http://172.28.0.10 inside stacka-net)"
echo "    Admin: admin / Welcome2024!"
echo "    Note:  This password is intentionally weak. It is the target of"
echo "           the T1110.001 brute-force step. Do not reuse it anywhere real."
