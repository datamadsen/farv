#!/usr/bin/env bash
# Handler: Wallpaper
# Purpose: Update desktop wallpaper when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/background.png" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Update wallpaper using swaybg if on Hyprland
    if has_command swaybg && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        pkill -x swaybg
        (setsid swaybg -i "$theme_path/background.png" -m fill >/dev/null 2>&1 &)
    fi
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "wallpaper"
fi