#!/bin/bash

# name: interfaces
# desc: Show network interfaces

source /opt/shared/lib/ui.sh

print_header "Network Interfaces"

ip -br addr
