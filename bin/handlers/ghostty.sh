#!/usr/bin/env bash
# Handler: Ghostty
# Purpose: Update ghostty configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }
is_running() { pgrep -x "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/ghostty" ] && has_command ghostty
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Reload Ghostty configuration if running
    if is_running ghostty; then
        ghostty_addresses=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')
        
        if [[ -n "$ghostty_addresses" ]]; then
            # Save current active window
            current_window=$(hyprctl activewindow -j | jq -r '.address')
            
            # Focus each ghostty window and send reload key combo
            while IFS= read -r address; do
                hyprctl dispatch sendshortcut "CTRL SHIFT, comma, address:$address"
            done <<< "$ghostty_addresses"
            
            # Return focus to original window
            if [[ -n "$current_window" ]]; then
                hyprctl dispatch focuswindow "address:$current_window"
            fi
        fi
    fi
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "ghostty"
fi