# Trigger ghostty config reload
if pgrep -x ghostty &>/dev/null; then
  ghostty_addresses=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')

  if [[ -n "$ghostty_addresses" ]]; then
    # Save current active window
    current_window=$(hyprctl activewindow -j | jq -r '.address')

    # Focus each ghostty window and send reload key combo
    while IFS= read -r address; do
      hyprctl dispatch focuswindow "address:$address" >/dev/null
      sleep 0.1
      hyprctl dispatch sendshortcut "CTRL SHIFT, comma, address:$address" >/dev/null
    done <<<"$ghostty_addresses"

    # Return focus to original window
    if [[ -n "$current_window" ]]; then
      hyprctl dispatch focuswindow "address:$current_window" >/dev/null
    fi
  fi
fi
