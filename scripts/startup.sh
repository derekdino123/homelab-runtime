#!/bin/bash

#name: startup
#desc: Bootstrap script for a new container

# =========================
# Terminal Colors
# =========================
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# =========================
# Helper Functions
# # =======================

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

print_error() {
    echo -e "${RED}✘ $1${NC}"
}

# =========================================
# Root Check
# =========================================

if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root"
    exit 1
fi

# =========================
# Start Script
# =========================

print_header "Updating System Packages"

apt update && apt upgrade -y

if [ $? -eq 0 ]; then
    print_success "System packages updated successfully"
else
    echo -e "${RED}✘ Failed to update packages${NC}"
    # exit 1 , UNCOMMENT FOR EXIT AFTER FAILED UPDATE
fi

# Install Packages
# =========================

print_header "Installing Required Packages"

apt install -y sudo git curl tree htop btop openssh-server

if [ $? -eq 0 ]; then
    print_success "Installed packages: sudo, git, curl, tree, htop, btop, openssh-server"
else
    print_error "Package installation failed"
    exit 1
fi



# Allow SSH
# =========================

print_header "Configuring SSH"

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

print_success "Enabled SSH root login with password authentication"

# Restart SSH Service
# =========================

print_header "Restarting SSH Service"

systemctl restart ssh

if [ $? -eq 0 ]; then
    print_success "SSH service restarted successfully"
else
    echo -e "${RED}✘ Failed to restart SSH service${NC}"
    exit 1
fi

# =========================================
# Configure Bash
# =========================================

print_header "Configuring Bash Colors and Prompt"

BASHRC_FILE="/root/.bashrc"

if ! grep -q "# HOMELAB-CUSTOMIZATION" "$BASHRC_FILE"; then

cat << 'EOF' >> "$BASHRC_FILE"

# =========================
# HOMELAB-CUSTOMIZATION
# =========================

# Color support
# =========================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Prompt
# =========================
PS1='\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ '

# Useful Aliases
# =========================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ipa='ip -c addr'
alias ipr='ip -c route'
alias ipn='ip -c neigh'

alias ports='ss -tulpn'
alias listen='ss -tulpn'

alias mem='free -h'
alias disk='df -h'
alias dns='cat /etc/resolv.conf'

alias update='apt update && apt upgrade -y'
alias myip='curl -4 ifconfig.me'

# Colorized Interface View
# =========================
ipinfo() {
    ip addr | awk '
    /^[0-9]+:/ {print "\033[1;34m" $0 "\033[0m"; next}
    /inet / {print "\033[1;32m" $0 "\033[0m"; next}
    {print}
    '
}

# Colorized Route Table
# =========================
routes() {
    ip route | awk '
    /^default/ {print "\033[1;31m" $0 "\033[0m"; next}
    {print "\033[1;32m" $0 "\033[0m"}
    '
}

# Bridge Information
# =========================
bridges() {
    bridge link show | awk '
    /master/ {print "\033[1;36m" $0 "\033[0m"; next}
    {print}
    '
}

# Network Summary
# =========================
netsummary() {

    echo
    echo "===== NETWORK SUMMARY ====="

    hostname -I | awk '{print "IP Address: \033[1;32m"$1"\033[0m"}'

    echo "Gateway: $(ip route | awk "/default/ {print \$3}")"

    echo "DNS:"
    grep nameserver /etc/resolv.conf

    echo
}

# =========================
# Login Network Check
# =========================
networkcheck() {

    IP=$(hostname -I | awk '{print $1}')
    GW=$(ip route | awk '/default/ {print $3}' | head -n1)

    DNS_SERVERS=$(grep '^nameserver' /etc/resolv.conf \
        | awk '{print $2}' \
        | paste -sd "," -)

    echo
    echo -e "\033[1;34m====================================\033[0m"
    echo -e " Host: \033[1;32m$(hostname)\033[0m"
    echo -e " IP:   \033[1;32m${IP}\033[0m"
    echo -e " GW:   \033[1;32m${GW}\033[0m"
    echo -e " DNS:  \033[1;32m${DNS_SERVERS}\033[0m"
    echo

    ping -c1 -W1 "$GW" >/dev/null 2>&1 \
        && echo -e " Gateway:  \033[0;32m✔\033[0m" \
        || echo -e " Gateway:  \033[0;31m✘\033[0m"

    ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 \
        && echo -e " Internet: \033[0;32m✔\033[0m" \
        || echo -e " Internet: \033[0;31m✘\033[0m"

    getent hosts google.com >/dev/null 2>&1 \
        && echo -e " DNS:      \033[0;32m✔\033[0m" \
        || echo -e " DNS:      \033[0;31m✘\033[0m"

    echo -e "\033[1;34m====================================\033[0m"
    echo
}

# Run automatically on login
networkcheck

EOF

    print_success "Bash customizations added"
else
    print_info "Bash customizations already exist"
fi

# =========================================
# Finish
# =========================================

print_header "Setup Complete"

print_success "System setup finished successfully"
print_info "Run: source $BASHRC_FILE"

source "$BASHRC_FILE"
