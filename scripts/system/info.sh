#!/bin/bash

# name: info
# desc: Show system status and inventory

source /opt/shared/lib/ui.sh

print_header "System Information"

print_info "Hostname"
hostname

echo
print_info "Operating System"
cat /etc/os-release | grep PRETTY_NAME

echo
print_info "Kernel"
uname -r

echo
print_info "Uptime"
uptime -p

echo
print_info "CPU"
lscpu | grep "Model name"

echo
print_info "Memory"
free -h

echo
print_info "Disk"
df -h /

echo
print_info "Network"
hostname -I

echo
print_info "Load"
uptime
