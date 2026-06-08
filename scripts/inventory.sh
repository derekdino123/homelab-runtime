source /shared/lib/ui.sh

# -----------------------
# Header
# -----------------------

header "System Inventory"

# Hostname
# -----------------------

echo -e " Hostname  ${GREEN}$(hostname)${NC}"

# Kernel
# -----------------------

echo -e " Kernel    ${YELLOW}$(uname -r)${NC}"

echo

# CPU
# -----------------------

CPU_MODEL=$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2}')

echo -e "${BLUE}CPU${NC}"
echo -e "  Model    ${GREEN}${CPU_MODEL}${NC}"

echo

# Memory
# -----------------------

echo -e "${BLUE}Memory${NC}"
free -h | awk 'NR==1 || /Mem:/ {
    printf "  %-8s %s %s %s %s %s %s\n", $1,$2,$3,$4,$5,$6,$7
}'

echo

# Disk
# -----------------------

echo -e "${BLUE}Disk${NC}"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | awk 'NR==1 || $0 !~ /loop/ {
    printf "  %-8s %-6s %-6s %s\n", $1,$2,$3,$4
}'

echo

# Network
# -----------------------

echo -e "${BLUE}Network${NC}"
ip -c addr | sed 's/^/  /'
