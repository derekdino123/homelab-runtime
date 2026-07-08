#!/bin/bash

# name: status
# desc: Check Pi-hole status and connection

# Checks connection to KeepAlived (192.168.1.112)

source /opt/shared/lib/ui.sh

print_header "Pi-hole Status"

if command -v pihole >/dev/null 2>&1; then

    print_info "Local Pi-hole Instance"

    systemctl is-active pihole-FTL \
        && print_success "FTL Running" \
        || print_error "FTL Down"

    echo

    pihole status

    echo

    pihole -v

else

    print_info "Remote Pi-hole Check"

    ping -c1 -W1 192.168.1.112 >/dev/null 2>&1 \
        && print_success "Pi-hole VIP Reachable" \
        || print_error "Pi-hole VIP Unreachable"

    echo

    dig google.com @192.168.1.112 +short >/dev/null 2>&1 \
        && print_success "DNS Working Through VIP" \
        || print_error "DNS Failed Through VIP"

fi
