#!/usr/bin/env bash

#name: update
#desc: Builds a Caddy binary with the Cloudflare module and installs it

#TODO: Update to use ui.sh lib

set -euo pipefail

CADDYFILE="/etc/caddy/Caddyfile"
MODULE="github.com/caddy-dns/cloudflare"

echo "==> Checking for root..."
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root or with sudo."
    exit 1
fi

echo "==> Current Caddy version:"
caddy version
echo

echo "==> Installing/updating Cloudflare DNS module..."
caddy add-package "$MODULE"

echo
echo "==> Verifying module installation..."
if ! caddy list-modules | grep -qx "dns.providers.cloudflare"; then
    echo "ERROR: Cloudflare DNS module was not installed."
    exit 1
fi

echo "✓ Cloudflare module detected."
echo

echo "==> Formatting Caddyfile..."
caddy fmt --overwrite "$CADDYFILE"

echo
echo "==> Validating configuration..."
caddy validate --config "$CADDYFILE"

echo
echo "==> Reloading Caddy..."
systemctl reload caddy

echo
echo "========================================"
echo "Caddy updated successfully!"
echo "========================================"
echo

echo "Installed DNS modules:"
caddy list-modules | grep '^dns.providers.' || true

echo
echo "Caddy version:"
caddy version

echo
echo "Service status:"
systemctl --no-pager --full status caddy
