#!/usr/bin/env bash
# Handler: Bat
# Purpose: Update bat configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/bat.conf" ] && [ -f "$HOME/.config/bat/config" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    local bat_config="$HOME/.config/bat/config"
    local base_bat_config="$HOME/dotfiles/bat/config"
    local temp_config="/tmp/bat_config_$$"
    
    # Create new config from theme-specific config
    cp "$theme_path/bat.conf" "$temp_config"
    echo "" >> "$temp_config"  # Add newline
    
    # Append base configuration (excluding theme line)
    grep -v "^--theme=" "$base_bat_config" >> "$temp_config"
    
    # Move to final location
    mv "$temp_config" "$bat_config"
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "bat"
fi