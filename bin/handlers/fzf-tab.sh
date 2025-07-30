#!/usr/bin/env bash
# Handler: fzf-tab
# Purpose: Update fzf-tab configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/fzf-tab.zsh" ] && typeset -f _fzf_tab_complete >/dev/null 2>&1
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Update fzf-tab theme in current shell
    source "$theme_path/fzf-tab.zsh"
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "fzf-tab"
fi