#!/usr/bin/env bash

echo "[farv] Installing farv system-wide..."
echo ""

# Check if we're in the right directory
if [ ! -f "bin/farv" ] || [ ! -d "themes" ]; then
  echo "[farv] Error: Must be run from the farv directory containing bin/farv and themes/"
  exit 1
fi

# Detect platform
PLATFORM="unknown"
case "$(uname -s)" in
Linux*) PLATFORM="linux" ;;
Darwin*) PLATFORM="macos" ;;
*) PLATFORM="unknown" ;;
esac

echo "[farv] Detected platform: $PLATFORM"

# Set platform-specific paths
if [ "$PLATFORM" = "macos" ]; then
  # macOS paths - prefer Homebrew locations
  if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)
    BIN_DIR="$BREW_PREFIX/bin"
    SHARE_DIR="$BREW_PREFIX/share"
  else
    # Fallback to /usr/local if no Homebrew
    BIN_DIR="/usr/local/bin"
    SHARE_DIR="/usr/local/share"
  fi
  BASH_COMPLETION_DIR="$SHARE_DIR/bash-completion/completions"
  ZSH_COMPLETION_DIR="$SHARE_DIR/zsh/site-functions"
  FISH_COMPLETION_DIR="$SHARE_DIR/fish/vendor_completions.d"
  SUDO_CMD="" # macOS users typically don't need sudo for /usr/local
elif [ "$PLATFORM" = "linux" ]; then
  # Linux paths
  BIN_DIR="/usr/bin"
  SHARE_DIR="/usr/share"
  BASH_COMPLETION_DIR="$SHARE_DIR/bash-completion/completions"
  ZSH_COMPLETION_DIR="$SHARE_DIR/zsh/site-functions"
  FISH_COMPLETION_DIR="$SHARE_DIR/fish/vendor_completions.d"
  SUDO_CMD="sudo"
else
  echo "[farv] Error: Unsupported platform. This installer supports Linux and macOS."
  exit 1
fi

echo "[farv] Installation paths:"
echo "  Binary: $BIN_DIR/"
echo "  Themes: $SHARE_DIR/farv/themes/"
echo "  Completions: $BASH_COMPLETION_DIR/, $ZSH_COMPLETION_DIR/, $FISH_COMPLETION_DIR/"
if [ "$PLATFORM" = "macos" ] && [ -z "$SUDO_CMD" ]; then
  echo "[farv] Note: Installing to user-writable locations (no sudo required)"
elif [ "$PLATFORM" = "linux" ]; then
  echo "[farv] Note: Installing to system directories (sudo required)"
fi
echo ""

# Install binary to system location
echo "[farv] Installing binary to $BIN_DIR/"
$SUDO_CMD cp bin/farv "$BIN_DIR/farv"
$SUDO_CMD chmod +x "$BIN_DIR/farv"

# Create system directories
echo "[farv] Creating system directories"
$SUDO_CMD mkdir -p "$SHARE_DIR/farv/themes/light"
$SUDO_CMD mkdir -p "$SHARE_DIR/farv/themes/dark"
$SUDO_CMD mkdir -p "$SHARE_DIR/farv/lib"

# Install system themes
echo "[farv] Installing system themes"
if [ -d "themes" ]; then
  # Copy theme directories
  if [ -d "themes/light" ]; then
    $SUDO_CMD cp -r themes/light/* "$SHARE_DIR/farv/themes/light/" 2>/dev/null || true
  fi
  if [ -d "themes/dark" ]; then
    $SUDO_CMD cp -r themes/dark/* "$SHARE_DIR/farv/themes/dark/" 2>/dev/null || true
  fi
  # Copy global theme files (not in light/dark subdirectories)
  for file in themes/*; do
    if [ -f "$file" ]; then
      $SUDO_CMD cp "$file" "$SHARE_DIR/farv/themes/" 2>/dev/null || true
    fi
  done
fi

# Install utility library
echo "[farv] Installing utility library"
if [ -d "lib" ]; then
  $SUDO_CMD cp -r lib/* "$SHARE_DIR/farv/lib/" 2>/dev/null || true
fi

# Install completions to system locations
echo "[farv] Installing completion scripts"
$SUDO_CMD mkdir -p "$BASH_COMPLETION_DIR" "$ZSH_COMPLETION_DIR" "$FISH_COMPLETION_DIR"

# Generate and install completions
echo "[farv] Generating completions..."
"$BIN_DIR/farv" --generate-completion bash | $SUDO_CMD tee "$BASH_COMPLETION_DIR/farv" >/dev/null
"$BIN_DIR/farv" --generate-completion zsh | $SUDO_CMD tee "$ZSH_COMPLETION_DIR/_farv" >/dev/null
"$BIN_DIR/farv" --generate-completion fish | $SUDO_CMD tee "$FISH_COMPLETION_DIR/farv.fish" >/dev/null

# Create user configuration directory (no sudo needed)
echo "[farv] Setting up user configuration"
FARV_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/farv"
mkdir -p "$FARV_CONFIG_HOME/themes/light" "$FARV_CONFIG_HOME/themes/dark"

# Create user config file
if [ ! -f "$FARV_CONFIG_HOME/config" ]; then
  echo "[farv] Creating user configuration file"
  cat >"$FARV_CONFIG_HOME/config" <<'EOF'
# Farv user configuration
# Uncomment and modify as needed

# HANDLER_TIMEOUT=10
# VERBOSE=true  
# DEFAULT_CATEGORY="dark"
EOF
fi

echo ""
echo "[farv] Installation complete!"
echo ""
echo "System installation:"
echo "  Binary: $BIN_DIR/farv"
echo "  Themes: $SHARE_DIR/farv/themes/"
echo "  Completions: $BASH_COMPLETION_DIR/, $ZSH_COMPLETION_DIR/, $FISH_COMPLETION_DIR/"
echo ""
echo "User configuration:"
echo "  Config: $FARV_CONFIG_HOME/"
echo "  Current theme: $FARV_CONFIG_HOME/current (after first theme switch)"
echo ""
echo "Usage:"
echo "  farv list           # List available themes"
echo "  farv <theme>        # Switch to theme"
echo "  farv                # Interactive selection"
echo ""
echo "Customization:"
echo "  $FARV_CONFIG_HOME/themes/       # Add your custom themes here"
echo "  Theme scripts are executable files within theme directories"
echo ""
if [ "$PLATFORM" = "macos" ]; then
  echo "Tab completion setup:"
  echo "  Bash: Add 'source $BASH_COMPLETION_DIR/farv' to ~/.bash_profile"
  echo "  Zsh: Completion should work automatically if using Homebrew zsh"
  echo "  Fish: Completion should work automatically"
else
  echo "Tab completion should work immediately in new shell sessions."
fi
echo "To test: open a new terminal and try 'farv <Tab>'"
