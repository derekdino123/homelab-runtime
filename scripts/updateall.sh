#!/bin/bash

echo "========================================"
echo " FULL SYSTEM UPDATE"
echo "========================================"

bash /opt/shared/scripts/update-system.sh
echo
bash /opt/shared/scripts/update-repo.sh

echo
echo "========================================"
echo " DONE"
echo "========================================"
