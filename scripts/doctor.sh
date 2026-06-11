#!/bin/bash

# name: doctor
# desc: Perform homelab health checks

source /opt/shared/lib/ui.sh

print_header "Homelab Doctor"

check() {

    local NAME="$1"
    local CMD="$2"

    if eval "$CMD" >/dev/null 2>&1; then
        print_success "$NAME"
    else
        print_error "$NAME"
    fi

}

# ========================================
# Basic Networking
# ========================================

GW=$(ip route | awk '/default/ {print $3}' | head -n1)

check "Gateway Reachable" \
    "ping -c1 -W1 $GW"

check "Internet Reachable" \
    "ping -c1 -W1 1.1.1.1"

check "DNS Resolution" \
    "getent hosts google.com"

# ========================================
# DNS Server Display
# ========================================

echo
print_info "Configured DNS Servers"

grep '^nameserver' /etc/resolv.conf

echo

# ========================================
# Docker
# ========================================

if command -v docker >/dev/null 2>&1; then

    check "Docker Installed" \
        "docker --version"

    check "Docker Running" \
        "systemctl is-active docker"

fi

# ========================================
# Caddy
# ========================================

if command -v caddy >/dev/null 2>&1; then

    check "Caddy Running" \
        "systemctl is-active caddy"

fi

# ========================================
# Pi-hole
# ========================================

if command -v pihole >/dev/null 2>&1; then

    check "Pi-hole FTL" \
        "systemctl is-active pihole-FTL"

fi

# ========================================
# NetBird
# ========================================

if command -v netbird >/dev/null 2>&1; then

    check "NetBird Running" \
        "systemctl is-active netbird"

fi

# ========================================
# Disk
# ========================================

echo
print_info "Disk Usage"

df -h /

echo

# ========================================
# Memory
# ========================================

print_info "Memory"

free -h

echo

# ========================================
# Failed Services
# ========================================

FAILED=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

if [ "$FAILED" -eq 0 ]; then
    print_success "No Failed Services"
else
    print_warning "$FAILED Failed Services"
    systemctl --failed
fi
