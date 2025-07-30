#!/usr/bin/env bash
# Handler: Neovim
# Purpose: Update neovim configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/neovim.lua" ] && has_command nvim
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_plugins_dir="$nvim_config_dir/lua/plugins"
    local theme_symlink="$nvim_plugins_dir/farv.lua"
    
    # Check if user has neovim configuration
    if [ -d "$nvim_config_dir" ] && [ -f "$nvim_config_dir/init.lua" ]; then
        # Check if theme symlink exists and points to farv
        if [ -L "$theme_symlink" ] && [[ "$(readlink "$theme_symlink")" == *"/.farv/"* ]]; then
            # Update existing farv theme symlink
            ln -sf "$theme_path/neovim.lua" "$theme_symlink"
        elif [ ! -e "$theme_symlink" ]; then
            # Create new theme symlink if it doesn't exist
            mkdir -p "$nvim_plugins_dir"
            ln -sf "$theme_path/neovim.lua" "$theme_symlink"
        fi
    fi
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "neovim"
fi