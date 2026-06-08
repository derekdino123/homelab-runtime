#!/bin/bash

REPO_DIR="/opt/shared"
BACKUP_DIR="/opt/shared_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo " Safe Git Mirror Sync"
echo "========================================"

# Ensure repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[INFO] No git repo found — cloning fresh copy..."
    git clone https://github.com/derekdino123/homelab.git "$REPO_DIR"
    echo "✔ Repository cloned"
    exit 0
fi

cd "$REPO_DIR"

# Fetch latest state
echo "[INFO] Fetching latest changes..."
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[INFO] Changes detected — preparing safe mirror sync..."

    # List files that would be deleted
    DELETES=$(git clean -nd | awk '{print $3}')
    if [ -n "$DELETES" ]; then
        echo "[INFO] Backing up files that would be deleted to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        for f in $DELETES; do
            mkdir -p "$BACKUP_DIR/$(dirname "$f")"
            mv "$f" "$BACKUP_DIR/$f"
        done
    fi

    # Hard reset to match GitHub
    git reset --hard origin/main

    # Clean any remaining untracked files
    git clean -fd

    echo "✔ Repository safely synchronized with GitHub"
    echo "[INFO] Backed up deleted files in $BACKUP_DIR"
else
    echo "✔ Already fully in sync with GitHub"
fi
