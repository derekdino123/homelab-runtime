#!/usr/bin/env bash

# =========================================
# Ubuntu Container Bootstrap Script
# Supports Ubuntu 20.04 / 22.04 / 24.04
# =========================================

set -o pipefail

# =========================
# Colors
# =========================

GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

header() {
    echo
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${BLUE}$1${RESET}"
    echo -e "${BLUE}========================================${RESET}"
    echo
}

success() {
    echo -e "${GREEN}✔ $1${RESET}"
}

info() {
    echo -e "${YELLOW}➜ $1${RESET}"
}

error() {
    echo -e "${RED}✘ $1${RESET}"
}

# =========================================
# Root Check
# =========================================

if [[ $EUID -ne 0 ]]; then
    error "Please run as root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# =========================================
# Update System
# =========================================

header "Updating Ubuntu"

apt update

if apt upgrade -y; then
    success "System updated."
else
    error "System update failed."
fi

# =========================================
# Install Packages
# =========================================

header "Installing Packages"

PACKAGES=(
    sudo
    git
    curl
    wget
    tree
    htop
    btop
    nano
    vim
    unzip
    zip
    net-tools
    iproute2
    dnsutils
    openssh-server
)

if apt install -y "${PACKAGES[@]}"; then
    success "Packages installed."
else
    error "Package installation failed."
    exit 1
fi

# =========================================
# Configure SSH
# =========================================

header "Configuring SSH"

SSH_CONFIG="/etc/ssh/sshd_config"

if [[ -f "$SSH_CONFIG" ]]; then

    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$SSH_CONFIG"

    success "SSH configured."

else
    error "Cannot find sshd_config"
fi

systemctl enable ssh

if systemctl restart ssh 2>/dev/null; then
    success "SSH restarted."
elif systemctl restart sshd 2>/dev/null; then
    success "SSHD restarted."
else
    error "Unable to restart SSH."
fi

# =========================================
# Bash Customization
# =========================================

header "Customizing Bash"

BASHRC="/root/.bashrc"

if ! grep -q "HOMELAB-CUSTOMIZATION" "$BASHRC"; then

cat <<'EOF' >> "$BASHRC"

# ==================================================
# HOMELAB-CUSTOMIZATION
# ==================================================

if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias update='apt update && apt upgrade -y'

alias ipa='ip -c addr'
alias ipr='ip -c route'
alias ports='ss -tulpn'
alias mem='free -h'
alias disk='df -h'
alias myip='curl -4 ifconfig.me'

ipinfo() {
    ip -c addr
}

routes() {
    ip -c route
}

networkcheck() {

    IP=$(hostname -I | awk '{print $1}')
    GW=$(ip route | awk '/default/ {print $3}')

    DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | paste -sd "," -)

    echo
    echo "=================================="
    echo " Host : $(hostname)"
    echo " IP   : $IP"
    echo " GW   : $GW"
    echo " DNS  : $DNS"
    echo

    ping -c1 -W1 "$GW" >/dev/null 2>&1 \
        && echo "Gateway  : ✔" \
        || echo "Gateway  : ✘"

    ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 \
        && echo "Internet : ✔" \
        || echo "Internet : ✘"

    getent hosts google.com >/dev/null 2>&1 \
        && echo "DNS      : ✔" \
        || echo "DNS      : ✘"

    echo "=================================="
    echo
}

networkcheck

EOF

    success "Bash configured."

else
    info "Bash already configured."
fi

# =========================================
# Finish
# =========================================

header "Complete"

success "Ubuntu bootstrap finished."

echo
echo "Run:"
echo "source /root/.bashrc"
echo
