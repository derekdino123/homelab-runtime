#!/bin/bash

#desc: Updates Debian apps and pulls from Github repo (updates all scripts)

echo "========================================"
echo " FULL SYSTEM UPDATE"
echo "========================================"

bash /opt/shared/scripts/update.sh
echo
bash /opt/shared/scripts/updategit.sh

echo
echo "========================================"
echo " DONE"
echo "========================================"
