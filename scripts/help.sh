#!/bin/bash

# name: help
# desc: Show all available homelab commands

BASE="/opt/shared/scripts"

echo
echo "====================================="
echo " Homelab Available Commands"
echo "====================================="
echo

if [ ! -d "$BASE" ]; then
    echo "Scripts directory not found:"
    echo "$BASE"
    exit 1
fi

# ========================================
# Root Commands
# ========================================

echo "[root]"

ROOT_FOUND=0

for script in "$BASE"/*.sh; do

    [ -f "$script" ] || continue

    ROOT_FOUND=1

    name=$(basename "$script" .sh)

    desc=$(grep -m1 '^#[ ]*desc:' "$script" \
        | sed 's/^#[ ]*desc:[ ]*//')

    [ -z "$desc" ] && desc="(no description)"

    printf "  %-15s - %s\n" "$name" "$desc"

done | sort

if [ "$ROOT_FOUND" -eq 0 ]; then
    echo "  (no commands)"
fi

echo

# ========================================
# Groups
# ========================================

for group in "$BASE"/*; do

    [ -d "$group" ] || continue

    group_name=$(basename "$group")

    echo "[$group_name]"

    scripts=("$group"/*.sh)

    if [ ! -f "${scripts[0]}" ]; then
        echo "  (no commands)"
        echo
        continue
    fi

    for script in "${scripts[@]}"; do

        name=$(basename "$script" .sh)

        desc=$(grep -m1 '^#[ ]*desc:' "$script" \
            | sed 's/^#[ ]*desc:[ ]*//')

        [ -z "$desc" ] && desc="(no description)"

        printf "  %-15s - %s\n" "$name" "$desc"

    done | sort

    echo

done

echo "Usage:"
echo "  homelab <command>"
echo "  homelab <group>"
echo "  homelab <group> <command>"
echo
