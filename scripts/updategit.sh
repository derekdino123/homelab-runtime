#!/bin/bash

#desc: Pulls Github repo (updates scripts)

set -e

REPO_DIR="/opt/shared"
BACKUP_DIR="/opt/shared_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo " SAFE GIT MIRROR UPDATE (PREVIEW MODE)"
echo "========================================"

# Ensure repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[INFO] No git repository found — cloning fresh copy..."
    rm -rf "$REPO_DIR"
    git clone https://github.com/derekdino123/homelab.git "$REPO_DIR"
    echo "✔ Repository cloned"
    exit 0
fi

cd "$REPO_DIR"

# ========================================
# 1. FETCH LATEST STATE
# ========================================
echo
echo "[INFO] Fetching latest changes..."
git fetch origin

# ========================================
# 2. CHECK FOR CHANGES
# ========================================
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✔ Already up to date"
    exit 0
fi

# ========================================
# 3. PREVIEW CHANGES
# ========================================
echo
echo "========================================"
echo " CHANGE SUMMARY"
echo "========================================"

CHANGES=$(git diff --name-status HEAD origin/main)

ADDED=$(echo "$CHANGES" | awk '$1=="A"{print $2}')
MODIFIED=$(echo "$CHANGES" | awk '$1=="M"{print $2}')
DELETED=$(echo "$CHANGES" | awk '$1=="D"{print $2}')

echo
echo "➕ Added files:"
[ -n "$ADDED" ] && echo "$ADDED" || echo "None"

echo
echo "✏️ Modified files:"
[ -n "$MODIFIED" ] && echo "$MODIFIED" || echo "None"

echo
echo "❌ Deleted files:"
[ -n "$DELETED" ] && echo "$DELETED" || echo "None"

echo
echo "========================================"
read -p "Apply these changes? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
    echo "❌ Update cancelled"
    exit 0
fi

# ========================================
# 4. SAFE BACKUP (DELETED FILES)
# ========================================
echo
echo "[INFO] Creating backup of files that will be removed..."

DELETES=$(git diff --name-status HEAD origin/main | awk '$1=="D"{print $2}')

if [ -n "$DELETES" ]; then
    mkdir -p "$BACKUP_DIR"

    for file in $DELETES; do
        if [ -e "$file" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv "$file" "$BACKUP_DIR/$file"
            echo "[BACKED UP] $file"
        fi
    done
fi

# ========================================
# 5. APPLY MIRROR SYNC
# ========================================
echo
echo "[INFO] Applying mirror update..."

git reset --hard origin/main
git clean -fd

# ========================================
# 6. FINAL STATUS
# ========================================
echo
echo "========================================"
echo " UPDATE COMPLETE"
echo "========================================"
echo "✔ Repository synchronized with GitHub"
echo "📦 Backup (if any deletions): $BACKUP_DIR"
echo "========================================"
