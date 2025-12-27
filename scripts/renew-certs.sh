#!/bin/bash
# Auto-renew Let's Encrypt certificates and reload nginx
# Run this via cron (e.g., daily or weekly)

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "[$(date)] Starting certificate renewal..."

# Run certbot renewal (checks for certs expiring in 30+ days, only renews if needed)
docker compose run --rm certbot renew --quiet

# Reload nginx to pick up new certs
echo "[$(date)] Reloading nginx..."
docker compose exec -T nginx nginx -s reload || echo "Nginx reload failed; check manually"

echo "[$(date)] Certificate renewal completed."
