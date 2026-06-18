#!/bin/bash

# name: help
# desc: Show all available homelab commands

BASE="/opt/shared/scripts"
UI="/opt/shared/lib/ui.sh"

# Load UI library
if [ -f "$UI" ]; then
    source "$UI"
else
    print_header() { echo -e "\n=== $1 ===\n"; }
    group_header() { echo -e "\n[$1]\n"; }
fi

print_header "Homelab Available Commands"

if [ ! -d "$BASE" ]; then
    echo "Scripts directory not found: $BASE"
    exit 1
fi

# ========================================
# ROOT COMMANDS
# ========================================

print_header "ROOT COMMANDS"

shopt -s nullglob
root_scripts=("$BASE"/*.sh)
shopt -u nullglob

if [ ${#root_scripts[@]} -eq 0 ]; then
    echo "  (no commands)"
else
    for script in "${root_scripts[@]}"; do

        name=$(basename "$script" .sh)

        desc=$(grep -m1 '^#[ ]*desc:' "$script" \
            | sed 's/^#[ ]*desc:[ ]*//')

        [ -z "$desc" ] && desc="(no description)"

        printf "  %-15s - %s\n" "$name" "$desc"

    done | sort
fi

echo

# ========================================
# GROUP COMMANDS
# ========================================

for group in "$BASE"/*; do

    [ -d "$group" ] || continue

    group_name=$(basename "$group")

    group_header "$group_name"

    shopt -s nullglob
    scripts=("$group"/*.sh)
    shopt -u nullglob

    if [ ${#scripts[@]} -eq 0 ]; then
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
