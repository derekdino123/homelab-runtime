#!/bin/bash

#name: install
#desc: Installs Docker CE and Compose

# ========================================
# Load Shared UI Library
# ========================================

source /opt/shared/lib/ui.sh

require_root

# ========================================
# Update Packages
# ========================================

print_header "Updating Packages"

apt update && apt upgrade -y

if [ $? -eq 0 ]; then
    print_success "System updated successfully"
else
    print_error "System update failed"
    exit 1
fi

# ========================================
# Install Prerequisites
# ========================================

print_header "Installing Docker Prerequisites"

apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

if [ $? -eq 0 ]; then
    print_success "Prerequisites installed"
else
    print_error "Failed to install prerequisites"
    exit 1
fi

# ========================================
# Detect Operating System
# ========================================

print_header "Detecting Operating System"

source /etc/os-release

case "$ID" in
    ubuntu)
        DOCKER_REPO="https://download.docker.com/linux/ubuntu"
        DOCKER_GPG="https://download.docker.com/linux/ubuntu/gpg"
        ;;

    debian)
        DOCKER_REPO="https://download.docker.com/linux/debian"
        DOCKER_GPG="https://download.docker.com/linux/debian/gpg"
        ;;

    *)
        print_error "Unsupported OS: $ID"
        exit 1
        ;;
esac

print_info "OS: $PRETTY_NAME"
print_info "Docker repository: $DOCKER_REPO"


# ========================================
# Add Docker Repository
# ========================================

print_header "Adding Docker Repository"

install -m 0755 -d /etc/apt/keyrings

if curl -fsSL "$DOCKER_GPG" -o /etc/apt/keyrings/docker.asc; then
    chmod a+r /etc/apt/keyrings/docker.asc
else
    print_error "Failed to download Docker GPG key"
    exit 1
fi

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
$DOCKER_REPO \
$VERSION_CODENAME stable" \
> /etc/apt/sources.list.d/docker.list


if apt update; then
    print_success "Docker repository added"
else
    print_error "Failed to add Docker repository"
    exit 1
fi

# ========================================
# Install Docker
# ========================================

print_header "Installing Docker Engine"

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

if [ $? -eq 0 ]; then
    print_success "Docker installed"
else
    print_error "Docker installation failed"
    exit 1
fi

# ========================================
# Enable Docker Service
# ========================================

print_header "Configuring Docker Service"

systemctl enable docker
systemctl start docker

if systemctl is-active --quiet docker; then
    print_success "Docker service running"
else
    print_error "Docker service failed to start"
    exit 1
fi

# ========================================
# Docker Aliases
# ========================================

print_header "Adding Docker Aliases"

if ! grep -q "# DOCKER-ALIASES" /root/.bashrc; then

cat << 'EOF' >> /root/.bashrc

# DOCKER-ALIASES

alias dps='docker ps'
alias dpa='docker ps -a'

alias di='docker images'

alias dlog='docker logs'

alias dstart='docker start'
alias dstop='docker stop'

alias dc='docker compose'

EOF

    print_success "Docker aliases added"
else
    print_info "Docker aliases already exist"
fi

# ========================================
# Verification
# ========================================

print_header "Verifying Installation"

docker --version
docker compose version

print_success "Docker installation completed"
