#!/bin/bash

# name: status
# desc: Check Caddy status and connection

# Checks connection to Caddy (192.168.1.11)

source /opt/shared/lib/ui.sh

print_header "Caddy Status"

if command -v caddy >/dev/null 2>&1; then

    print_info "Local Caddy Instance"

    systemctl is-active caddy \
        && print_success "Service Running" \
        || print_error "Service Down"

    echo

    print_info "Listening Ports"

    ss -tulpn | grep -E ':80|:443'

    echo

    print_info "Loaded Configuration"

    caddy validate

    echo

    print_info "Certificates"

    find /var/lib/caddy/.local/share/caddy/certificates \
        -type f 2>/dev/null | head

else

    print_info "Remote Caddy Check"

    ping -c1 -W1 192.168.1.11 >/dev/null 2>&1 \
        && print_success "Caddy Reachable" \
        || print_error "Caddy Unreachable"

fi
