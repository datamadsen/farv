source /usr/share/farv/lib/utils.sh

if has_command "claude"; then
  # Set Claude Code theme by modifying ~/.claude.json
  if [ -f ~/.claude.json ]; then
    # Use jq to add or update the theme field
    tmp=$(mktemp)
    jq '. + {"theme": "light"}' ~/.claude.json > "$tmp" && mv "$tmp" ~/.claude.json
  else
    # Create the file with theme setting if it doesn't exist
    echo '{"theme": "light"}' > ~/.claude.json
  fi
fi
