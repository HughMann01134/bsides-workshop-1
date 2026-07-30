#!/bin/bash
# Resets stack-a/target to a clean, freshly-provisioned state.
# Run this before any real attack-chain capture run — dev/test iterations
# leave behind extra posts, uploaded files, and log noise that don't belong
# in a real log bundle.
set -euo pipefail

cd "$(dirname "$0")"

echo "[*] Tearing down containers and volumes (db_data, wp_data)..."
docker compose down -v

echo "[*] Bringing up db + wordpress..."
docker compose up -d db wordpress

echo "[*] Waiting for services to settle..."
sleep 15

echo "[*] Re-provisioning (WordPress core + wpDiscuz 7.0.4)..."
docker compose run --rm provision

echo "[*] Reset complete. Target is at a clean, freshly-provisioned state."
echo "    Apache logs, wp_content/uploads, and the database have all been"
echo "    reset — no dev-testing artifacts remain."