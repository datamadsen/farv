#!/bin/bash
# Set bat theme for gruvbox-light

# Check if bat exists
if ! command -v bat &>/dev/null; then
  exit 0
fi

# Bat config file location
BAT_CONFIG="$HOME/.config/bat/config"

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$BAT_CONFIG")"

# Create config file if it doesn't exist
if [ ! -f "$BAT_CONFIG" ]; then
  touch "$BAT_CONFIG"
fi

# Check if theme line exists
if grep -q "^--theme=" "$BAT_CONFIG"; then
  # Replace existing theme line
  sed -i 's/^--theme=.*$/--theme="gruvbox-light"/' "$BAT_CONFIG"
else
  # Add theme line at the bottom
  echo '--theme="gruvbox-light"' >> "$BAT_CONFIG"
fi
