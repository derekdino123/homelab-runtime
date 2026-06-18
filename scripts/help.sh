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

for group in "$BASE"/*; do

    [ -d "$group" ] || continue

    group_name=$(basename "$group")

    echo "[$group_name]"

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
echo "  homelab <group> <command>"
echo
