#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command swaybg; then
  exit 0
fi

# Check if swaybg is currently running
if ! pgrep -x swaybg &>/dev/null; then
  exit 0
fi

# Look for wallpaper files in the current theme directory
THEME_DIR="$XDG_CONFIG_HOME/farv/current"
WALLPAPER=""

if [[ -f "$THEME_DIR/wallpaper.jpg" ]]; then
  WALLPAPER="$THEME_DIR/wallpaper.jpg"
elif [[ -f "$THEME_DIR/wallpaper.png" ]]; then
  WALLPAPER="$THEME_DIR/wallpaper.png"
else
  log_action "No wallpaper .jpg or .png found in theme directory ($THEME_DIR)."
  exit 0
fi

# Set wallpaper using setsid approach
setsid swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
