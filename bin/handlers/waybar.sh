#!/usr/bin/env bash
# Handler: Waybar
# Purpose: Update waybar configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }
is_running() { pgrep -x "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/waybar.css" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Reload waybar if running
    if has_command waybar && is_running waybar; then
        pkill -SIGUSR2 waybar 2>/dev/null || true
    fi
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "waybar"
fi