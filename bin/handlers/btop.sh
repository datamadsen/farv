#!/usr/bin/env bash
# Handler: Btop
# Purpose: Update btop configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/btop.theme" ] && [ -f "$HOME/.config/btop/btop.conf" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    mkdir -p "$HOME/.config/btop/themes"
    ln -sf "$theme_path/btop.theme" "$HOME/.config/btop/themes/current.theme"
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "btop"
fi