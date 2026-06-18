```bash
#!/bin/bash

# name
# desc: Check the health of Docker containers

source /opt/shared/lib/ui.sh

print_header "Docker Health"

if ! systemctl is-active docker >/dev/null 2>&1; then
    print_error "Docker service not running"
    exit 1
fi

print_success "Docker service running"

echo

docker ps --format \
'{{.Names}} {{.Status}}'
```