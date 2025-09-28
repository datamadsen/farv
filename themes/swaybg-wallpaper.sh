#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command swaybg; then
  exit 0
fi

# Check if swaybg is currently running
if ! pgrep -x swaybg &>/dev/null; then
  exit 0
fi

# Look for current-background in the backgrounds folder
THEME_DIR="$XDG_CONFIG_HOME/farv/current"
WALLPAPER=""

# Use current selection from backgrounds folder
if [[ -L "$THEME_DIR/backgrounds/current-background" ]]; then
  WALLPAPER=$(readlink "$THEME_DIR/backgrounds/current-background")
  # Resolve relative symlinks
  if [[ ! "$WALLPAPER" = /* ]]; then
    WALLPAPER="$THEME_DIR/backgrounds/$WALLPAPER"
  fi
else
  log_action "No current-background symlink found in $THEME_DIR/backgrounds/"
  exit 0
fi

# Set wallpaper using setsid approach
setsid swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
