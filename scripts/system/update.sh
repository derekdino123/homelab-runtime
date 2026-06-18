updates Linux system

``` bash
#!/bin/bash

#name: update
#desc: Updates Debian apps

source /opt/shared/lib/ui.sh

echo "========================================"
echo " System Update"
echo "========================================"

apt update &&
apt upgrade -y &&
apt autoremove -y

echo

if [ -f /var/run/reboot-required ]; then
    echo "⚠ Reboot Required"
else
    echo "✔ No reboot required"
fi

echo
df -h /
```