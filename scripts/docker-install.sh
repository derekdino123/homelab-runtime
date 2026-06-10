#!/bin/bash
set -e

# ========================================
# Load Shared UI Library
# ========================================

source /opt/shared/lib/ui.sh

require_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run as root"
        exit 1
    fi
}

require_root

# ========================================
# Update Packages
# ========================================

header "Updating Packages"

apt-get update
apt-get upgrade -y

success "System updated successfully"

# ========================================
# Install Prerequisites
# ========================================

header "Installing Docker Prerequisites"

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

success "Prerequisites installed"

# ========================================
# Detect OS
# ========================================

header "Detecting Operating System"

. /etc/os-release

case "$ID" in
    ubuntu)
        DOCKER_REPO="https://download.docker.com/linux/ubuntu"
        ;;
    debian)
        DOCKER_REPO="https://download.docker.com/linux/debian"
        ;;
    *)
        error "Unsupported OS: $ID"
        exit 1
        ;;
esac

info "Detected: $PRETTY_NAME"

# ========================================
# Add Docker Repository
# ========================================

header "Adding Docker Repository"

install -m 0755 -d /etc/apt/keyrings

curl -fsSL "$DOCKER_REPO/gpg" \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_REPO $VERSION_CODENAME stable
EOF

if apt-get update; then
    success "Docker repository added"
else
    error "Failed to add Docker repository"
    exit 1
fi

# ========================================
# Install Docker
# ========================================

header "Installing Docker Engine"

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

success "Docker installed"

# ========================================
# Enable Docker
# ========================================

header "Configuring Docker Service"

systemctl enable docker
systemctl restart docker

if systemctl is-active --quiet docker; then
    success "Docker service running"
else
    error "Docker service failed to start"
    exit 1
fi

# ========================================
# Add Docker Aliases
# ========================================

header "Adding Docker Aliases"

if ! grep -q "# DOCKER-ALIASES" /root/.bashrc; then

cat << 'EOF' >> /root/.bashrc

# DOCKER-ALIASES

alias dps='docker ps'
alias dpa='docker ps -a'

alias di='docker images'

alias dlog='docker logs'

alias dstart='docker start'
alias dstop='docker stop'
alias drestart='docker restart'

alias dc='docker compose'

EOF

    success "Docker aliases added"
else
    info "Docker aliases already exist"
fi

# ========================================
# Verify Installation
# ========================================

header "Verifying Installation"

docker --version
docker compose version

echo
success "Docker installation completed"

echo
info "Run:"
echo "source ~/.bashrc"
echo

info "Useful commands:"
echo "dps        - Running containers"
echo "dpa        - All containers"
echo "di         - Docker images"
echo "dc ps      - Docker Compose status"
echo
