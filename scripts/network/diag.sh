#!/bin/bash

# name: diag
# desc: Run network diagnostics

source /opt/shared/lib/ui.sh

print_header "Network Diagnostics"

GW=$(ip route | awk '/default/ {print $3}' | head -n1)

print_info "IP Addresses"
hostname -I

echo
print_info "Gateway"
echo "$GW"

echo
print_info "DNS Servers"
grep '^nameserver' /etc/resolv.conf

echo

check() {

    local NAME="$1"
    local CMD="$2"

    if eval "$CMD" >/dev/null 2>&1; then
        print_success "$NAME"
    else
        print_error "$NAME"
    fi
}

check "Gateway Reachable" \
    "ping -c1 -W1 $GW"

check "Internet Reachable" \
    "ping -c1 -W1 1.1.1.1"

check "DNS Resolution" \
    "getent hosts google.com"
