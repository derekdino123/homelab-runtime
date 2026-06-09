#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✔${NC} $1"
}

error() {
    echo -e "${RED}✘${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

header() {
    echo
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}====================================${NC}"
}

# Compatibility aliases

print_success() { success "$1"; }
print_error()   { error "$1"; }
print_warning() { warning "$1"; }
print_info()    { info "$1"; }
print_header()  { header "$1"; }

require_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run as root"
        exit 1
    fi
}
