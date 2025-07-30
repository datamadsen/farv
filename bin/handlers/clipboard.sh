#!/usr/bin/env bash
# Handler: Clipboard (wofi)
# Purpose: Update clipboard styling when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
  [ -f "$theme_path/wofi-clipboard.css" ] && has_command wofi
}

# Main execution
theme_path="$1"
if check_availability; then
  log_action "wofi clipboard"
fi
