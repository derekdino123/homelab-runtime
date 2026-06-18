#!/bin/bash

# name: dns
# desc: DNS diagnostics

source /opt/shared/lib/ui.sh

print_header "DNS Diagnostics"

print_info "Configured DNS"

grep '^nameserver' /etc/resolv.conf

echo

for domain in google.com github.com cloudflare.com
do

    print_info "Resolving $domain"

    if getent hosts "$domain"; then
        print_success "$domain resolved"
    else
        print_error "$domain failed"
    fi

    echo

done
