#!/usr/bin/env bash
# Handler: Tmux
# Purpose: Update tmux configuration when theme changes

# Utility functions
log_action() { echo "  - $1"; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/tmux.conf" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Reload tmux configuration if tmux is running
    if has_command tmux && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
    fi
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "tmux"
fi