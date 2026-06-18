#!/bin/bash

# name: help
# desc: Show all available homelab commands

BASE="/opt/shared/scripts"
UI="/opt/shared/lib/ui.sh"

# Load UI library
if [ -f "$UI" ]; then
    source "$UI"
else
    # fallback if UI missing
    header() { echo -e "\n=== $1 ===\n"; }
fi

header "Homelab Available Commands"

if [ ! -d "$BASE" ]; then
    echo "Scripts directory not found: $BASE"
    exit 1
fi

# ========================================
# ROOT COMMANDS
# ========================================

print_header "ROOT COMMANDS"

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
# GROUP COMMANDS
# ========================================

for group in "$BASE"/*; do

    [ -d "$group" ] || continue

    group_name=$(basename "$group")

    print_header "$group_name"

    found=0

    for script in "$group"/*.sh; do
        [ -f "$script" ] || continue
        found=1

        name=$(basename "$script" .sh)

        desc=$(grep -m1 '^#[ ]*desc:' "$script" \
            | sed 's/^#[ ]*desc:[ ]*//')

        [ -z "$desc" ] && desc="(no description)"

        printf "  %-15s - %s\n" "$name" "$desc"
    done | sort

    if [ "$found" -eq 0 ]; then
        echo "  (no commands)"
    fi

    echo

done

echo "Usage:"
echo "  homelab <command>"
echo "  homelab <group>"
echo "  homelab <group> <command>"
echo
