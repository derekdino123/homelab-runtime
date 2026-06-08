#!/bin/bash

REPO_DIR="/opt/shared"
BACKUP_DIR="/opt/shared_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo " SAFE GIT MIRROR (WITH PREVIEW)"
echo "========================================"

# Ensure repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[INFO] No repo found — cloning fresh copy..."
    git clone https://github.com/derekdino123/homelab.git "$REPO_DIR"
    echo "✔ Repository cloned"
    exit 0
fi

cd "$REPO_DIR"

echo "[INFO] Fetching latest changes..."
git fetch origin

# ========================================
# 1. SHOW FILE CHANGES (PREVIEW MODE)
# ========================================

echo
echo "===== PREVIEW: FILE CHANGES ====="

CHANGES=$(git diff --name-status HEAD origin/main)

if [ -z "$CHANGES" ]; then
    echo "✔ No changes detected"
    exit 0
fi

ADDED=$(echo "$CHANGES" | awk '$1=="A"{print $2}')
MODIFIED=$(echo "$CHANGES" | awk '$1=="M"{print $2}')
DELETED=$(echo "$CHANGES" | awk '$1=="D"{print $2}')

echo
echo "➕ Added files:"
echo "$ADDED"

echo
echo "✏️ Modified files:"
echo "$MODIFIED"

echo
echo "❌ Deleted files:"
echo "$DELETED"

echo
echo "========================================"
read -p "Apply these changes? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
    echo "❌ Update cancelled"
    exit 0
fi

# ========================================
# 2. SAFE BACKUP OF FILES THAT WILL BE LOST
# ========================================

echo "[INFO] Creating backup of deletions (if any)..."

DELETES=$(git clean -nd | awk '{print $3}')

if [ -n "$DELETES" ]; then
    mkdir -p "$BACKUP_DIR"
    for f in $DELETES; do
        if [ -e "$f" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$f")"
            mv "$f" "$BACKUP_DIR/$f"
            echo "[BACKUP] $f"
        fi
    done
fi

# ========================================
# 3. APPLY MIRROR SYNC
# ========================================

echo "[INFO] Syncing repository..."

git reset --hard origin/main
git clean -fd

echo "✔ Repository successfully synchronized"

# ========================================
# 4. FINAL SUMMARY
# ========================================

echo
echo "===== DONE ====="
echo "✔ Repo is now identical to GitHub"
echo "📦 Backup of deleted files: $BACKUP_DIR"
echo "========================================"
