#!/bin/bash

REPO_DIR="/opt/shared"

echo "========================================"
echo " Git Update (Homelab Scripts)"
echo "========================================"

if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"

    git fetch origin

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "⬆ Updates found — pulling..."
        git pull --rebase origin main
        echo "✔ Scripts updated"
    else
        echo "✔ Already up to date"
    fi
else
    echo "❌ Not a git repository at $REPO_DIR"
fi
