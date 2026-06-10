#!/bin/bash

#desc: Displays the current network configuration of this container

source /opt/shared/lib/ui.sh

# -----------------------
# Helpers
# -----------------------

run_check() {
    local name="$1"
    local cmd="$2"

    printf "%-12s " "$name"

    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✔${NC}"
    else
        echo -e "${RED}✘${NC}"
    fi
}

disk_color() {
    local pct="$1"

    pct="${pct%\%}"

    if [ "$pct" -lt 70 ]; then
        echo -e "${GREEN}${1}${NC}"
    elif [ "$pct" -lt 85 ]; then
        echo -e "${YELLOW}${1}${NC}"
    else
        echo -e "${RED}${1}${NC}"
    fi
}

# -----------------------
# System info
# -----------------------

HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')
GW=$(ip route | awk '/default/ {print $3}' | head -n1)

DNS=$(grep '^nameserver' /etc/resolv.conf \
    | awk '{print $2}' \
    | paste -sd "," -)

UPTIME=$(uptime -p | sed 's/up //')

MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')

DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PCT_RAW=$(df -h / | awk 'NR==2 {print $5}')

FAILED_SERVICES=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

# -----------------------
# Header
# -----------------------

header "LXC Health Report"

echo -e " Host: ${GREEN}${HOST}${NC}"
echo -e " IP:   ${GREEN}${IP}${NC}"
echo -e " GW:   ${GREEN}${GW:-N/A}${NC}"
echo -e " DNS:  ${GREEN}${DNS:-N/A}${NC}"
echo -e " Up:   ${GREEN}${UPTIME}${NC}"

echo

# -----------------------
# Connectivity
# -----------------------

run_check "Gateway"  "ping -c1 -W1 $GW"
run_check "Internet" "ping -c1 -W1 1.1.1.1"
run_check "DNS"      "getent hosts google.com"

echo

# -----------------------
# Memory + disk
# -----------------------

echo -e " Memory     ${YELLOW}${MEM_USED}${NC} / ${YELLOW}${MEM_TOTAL}${NC}"

DISK_PCT=$(disk_color "$DISK_PCT_RAW")

echo -e " Disk       ${YELLOW}${DISK_USED}${NC} / ${YELLOW}${DISK_TOTAL}${NC} (${DISK_PCT})"

# -----------------------
# Services
# -----------------------

if [ "$FAILED_SERVICES" -eq 0 ]; then
    echo -e " Services   ${GREEN}✔ none failed${NC}"
else
    echo -e " Services   ${RED}✘ ${FAILED_SERVICES} failed${NC}"
fi

echo
