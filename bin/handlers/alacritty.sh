#!/usr/bin/env bash
# Handler: Alacritty
# Purpose: Update alacritty configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }

# Check if application is available and configured
check_availability() {
    [ -f "$HOME/.config/alacritty/alacritty.toml" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Touch the main alacritty config to trigger reload
    touch "$HOME/.config/alacritty/alacritty.toml"
}

# Main execution
if check_availability; then
    apply_theme "$1"
    log_action "alacritty"
fi