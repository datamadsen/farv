#!/usr/bin/env bash

echo "[farv] Reinstalling farv..."
echo "[farv] This will uninstall and reinstall farv, preserving your configuration."
echo ""

# Check if we're in the right directory
if [ ! -f "bin/farv" ] || [ ! -d "themes" ]; then
  echo "[farv] Error: Must be run from the farv directory containing bin/farv and themes/"
  exit 1
fi

# Check if required scripts exist
if [ ! -f "uninstall.sh" ] || [ ! -f "install.sh" ]; then
  echo "[farv] Error: uninstall.sh and install.sh must be present in the current directory"
  exit 1
fi

# Capture current theme before uninstall
echo "[farv] Detecting current theme..."
CURRENT_THEME=$(farv current 2>/dev/null)

if [ -n "$CURRENT_THEME" ]; then
  echo "[farv] Current theme detected: $CURRENT_THEME"
  echo "[farv] This theme will be reapplied after reinstall"
else
  echo "[farv] No active theme detected"
fi

echo ""

# Run uninstall (this will prompt for confirmation)
echo "[farv] Step 1/3: Uninstalling..."
if ! ./uninstall.sh; then
  echo ""
  echo "[farv] Reinstall cancelled or uninstall failed."
  exit 1
fi

echo ""

# Run install
echo "[farv] Step 2/3: Installing..."
if ! ./install.sh; then
  echo ""
  echo "[farv] Error: Installation failed!"
  echo "[farv] Your system may be in an inconsistent state."
  exit 1
fi

echo ""

# Reapply theme if one was active
if [ -n "$CURRENT_THEME" ]; then
  echo "[farv] Step 3/3: Reapplying theme..."
  echo ""

  if farv use "$CURRENT_THEME"; then
    echo ""
    echo "[farv] Reinstall complete! Theme '$CURRENT_THEME' has been reapplied."
  else
    echo ""
    echo "[farv] Warning: Could not reapply theme '$CURRENT_THEME'"
    echo "[farv] The theme may no longer exist or there was an error."
    echo "[farv] Run 'farv list' to see available themes."
    echo "[farv] Run 'farv use <theme>' to apply a theme manually."
  fi
else
  echo "[farv] Step 3/3: Skipping theme reapplication (no theme was active)"
  echo ""
  echo "[farv] Reinstall complete!"
  echo "[farv] Run 'farv use <theme>' to activate a theme."
fi

echo ""
