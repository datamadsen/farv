#!/usr/bin/env bash
# Handler: GTK
# Purpose: Update GTK theme settings when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    # Determine theme category
    if [[ "$theme_path" == *"/light/"* ]]; then
        theme_category="light"
    elif [[ "$theme_path" == *"/dark/"* ]]; then
        theme_category="dark"
    else
        return 1
    fi
    
    # Check for theme-specific or category-level GTK script
    local theme_specific_script="$theme_path/gtk.sh"
    local category_script="$HOME/.farv/themes/$theme_category/gtk.sh"
    
    if [ -f "$theme_specific_script" ] && [ -x "$theme_specific_script" ]; then
        gtk_script="$theme_specific_script"
        return 0
    elif [ -f "$category_script" ] && [ -x "$category_script" ]; then
        gtk_script="$category_script"
        return 0
    else
        return 1
    fi
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Check if we're in a GNOME/GTK environment
    if [ -n "$XDG_CURRENT_DESKTOP" ] && has_command gsettings && [ -n "$gtk_script" ]; then
        "$gtk_script" >/dev/null 2>&1
    fi
}

# Main execution
theme_path="$1"
gtk_script=""
if check_availability; then
    apply_theme "$1"
    log_action "gtk"
fi