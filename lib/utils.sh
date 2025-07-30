#!/usr/bin/env bash
# Farv utility functions library
# This file contains common utility functions used across farv components

# Logging function for consistent output formatting
log_action() { 
    echo "  - $1"
}

# Check if a process is currently running
is_running() { 
    pgrep -x "$1" >/dev/null 2>&1
}

# Check if a command is available in PATH
has_command() { 
    command -v "$1" >/dev/null 2>&1
}