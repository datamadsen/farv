#!/usr/bin/env bash

echo "[farv] Uninstalling farv system installation..."
echo "[farv] This will remove farv from system directories and requires sudo access."
echo ""

# Confirm with user
read -p "Are you sure you want to uninstall farv? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "[farv] Uninstall cancelled."
    exit 1
fi

echo "[farv] Removing system files..."

# Remove binary
if [ -f "/usr/bin/farv" ]; then
    sudo rm /usr/bin/farv
    echo "[farv] Removed /usr/bin/farv"
fi

# Remove system directories
if [ -d "/usr/share/farv" ]; then
    sudo rm -rf /usr/share/farv
    echo "[farv] Removed /usr/share/farv"
fi

# Remove completion scripts
echo "[farv] Removing completion scripts..."
if [ -f "/usr/share/bash-completion/completions/farv" ]; then
    sudo rm /usr/share/bash-completion/completions/farv
    echo "[farv] Removed bash completion"
fi

if [ -f "/usr/share/zsh/site-functions/_farv" ]; then
    sudo rm /usr/share/zsh/site-functions/_farv
    echo "[farv] Removed zsh completion"
fi

if [ -f "/usr/share/fish/vendor_completions.d/farv.fish" ]; then
    sudo rm /usr/share/fish/vendor_completions.d/farv.fish
    echo "[farv] Removed fish completion"
fi

echo ""
echo "[farv] System uninstall complete!"
echo ""
echo "Note: User configuration preserved at:"
echo "  ${XDG_CONFIG_HOME:-$HOME/.config}/farv/"
echo ""
echo "To completely remove farv including user config:"
echo "  rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/farv/"
echo ""
echo "You may need to restart your shell for tab completion changes to take effect."