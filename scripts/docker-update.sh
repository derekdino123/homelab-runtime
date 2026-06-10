#!/bin/bash

#name: docker-update
#desc: Controlled deployment of updating Docker

set -e

# ========================================
# Load Shared UI Library
# ========================================
source /opt/shared/lib/ui.sh
require_root

# ========================================
# Docker Update Script
# ========================================
print_header "Starting Docker Update"

# Directory where your Docker Compose projects live
DOCKER_DIRS=(/opt/shared/docker/*)  # adjust this path if needed

for dir in "${DOCKER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_info "Updating Docker project in: $dir"
        cd "$dir"

        # Pull new images
        if docker compose pull; then
            print_success "Pulled latest images in $dir"
        else
            print_error "Failed to pull images in $dir"
            continue
        fi

        # Show which services will be recreated
        print_info "Checking which services will be recreated..."
        docker compose config --services | while read service; do
            print_info "Service: $service"
        done

        # Bring up updated containers
        if docker compose up -d; then
            print_success "Updated containers for $dir"
        else
            print_error "Failed to update containers in $dir"
        fi

        # Show status
        docker compose ps
        echo
    else
        print_info "No Docker project found in $dir, skipping..."
    fi
done

print_success "Docker update completed!"
