#!/bin/bash

#name: help
#desc: Shows all available commands

BASE="/opt/shared/scripts"

echo ""
echo "====================================="
echo " Homelab Available Commands"
echo "====================================="
echo ""

if [ ! -d "$BASE" ]; then
    echo "No scripts directory found: $BASE"
    exit 1
fi

for script in "$BASE"/*.sh; do
    [ -f "$script" ] || continue

    name=$(basename "$script" .sh)

    # extract name and description from header:
    name=$(grep -m 1 "^# *name:" "$script" | sed 's/^# *name:[[:space:]]*//')
    desc=$(grep -m 1 "^# *desc:" "$script" | sed 's/^# *desc:[[:space:]]*//')

    if [ -z "$desc" ]; then
        desc="(no description)"
    fi

    printf "%-20s - %s\n" "$name" "$desc"
done | sort

echo ""
echo "Usage:"
echo "  homelab <command>"
echo ""
