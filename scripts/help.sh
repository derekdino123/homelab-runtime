- shows all available dispatcher commands

```bash
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

    # extract description from: # desc:
    desc=$(grep -m 1 "^# desc:" "$script" 2>/dev/null | sed 's/# desc:[ ]*//')

    if [ -z "$desc" ]; then
        desc="(no description)"
    fi

    printf "%-20s - %s\n" "$name" "$desc"
done | sort

echo ""
echo "Usage:"
echo "  homelab <command>"
echo ""
```