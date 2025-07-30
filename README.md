# farv - A friend in rice is a friend that's nice :-)

A comprehensive theme management system for Linux desktop environments that
provides unified theming across multiple applications and system components.

## Overview

**farv** is a hierarchical theme management system designed for "rice"
enthusiasts - users who customize their Linux desktop environments. It
provides a unified way to switch between complete theme configurations that can
affect multiple applications simultaneously, including terminal emulators,
window managers, status bars, and system UI components.

### Key Features

- **Hierarchical Theme System**: Themes are organized with inheritance and
  layering support
- **Multi-Application Support**: Single command affects multiple applications
  (alacritty, ghostty, waybar, hyprland, etc.)
- **User/System Theme Separation**: System-wide themes with user override
  capability
- **Interactive Selection**: Built-in fzf integration for easy theme browsing
- **Shell Completion**: Auto-completion support for bash, zsh, and fish
- **XDG Compliance**: Follows XDG Base Directory specification

## Architecture

### Directory Structure

```
/usr/share/farv/                    # System installation
├── themes/
│   ├── light/                      # Light theme category
│   │   └── rose-pine-dawn/         # Individual theme
│   │       ├── alacritty.toml      # Application config files
│   │       ├── hyprland.conf
│   │       ├── waybar.css
│   │       └── background.png
│   └── dark/                       # Dark theme category
│       └── tokyonight-night/
│           ├── alacritty.toml
│           ├── ghostty
│           └── ...
└── lib/
    └── utils.sh                    # Utility functions

~/.config/farv/                     # User configuration
├── themes/                         # User custom themes
│   ├── light/
│   └── dark/
├── current/                        # Symlinks to active theme files
└── config                          # User configuration file
```

### Theme Resolution Priority

farv uses a layered resolution system where files are resolved in priority
order:

1. **User theme-specific** (`~/.config/farv/themes/{category}/{theme}/`)
2. **System theme-specific** (`/usr/share/farv/themes/{category}/{theme}/`)
3. **User category-level** (`~/.config/farv/themes/{category}/`)
4. **System category-level** (`/usr/share/farv/themes/{category}/`)
5. **User global** (`~/.config/farv/themes/`)
6. **System global** (`/usr/share/farv/themes/`)

This allows users to override specific files from system themes or create
partial themes that inherit most files from parent layers.

## Installation

### System-wide Installation

```bash
# Clone the repository
git clone <repository-url> farv
cd farv

# Install system-wide (requires sudo)
./install-system.sh
```

This installs:
- Binary to `/usr/bin/farv`
- System themes to `/usr/share/farv/themes/`
- Shell completions to system locations
- Creates user config directory at `~/.config/farv/`

### Manual Installation

Copy `bin/farv` to a directory in your `$PATH` and ensure the required
directory structure exists.

## Usage

### Basic Commands

```bash
# List all available themes
farv list

# Switch to a specific theme
farv rose-pine-dawn
farv tokyonight-night

# Interactive theme selection (requires fzf)
farv

# Show help
farv --help
```

### Theme Format Examples

```bash
# Theme names as shown by 'farv list'
rose-pine-dawn (light)              # System theme
tokyonight-night (dark) [user]      # User theme
```

### Shell Completion Setup

Completions are automatically installed during system installation. For manual
setup:

```bash
# Generate completion scripts
farv --generate-completion bash > ~/.bash_completion.d/farv
farv --generate-completion zsh > ~/.local/share/zsh/site-functions/_farv
farv --generate-completion fish > ~/.config/fish/completions/farv.fish
```

## Creating Themes

### Theme Structure

A theme is a directory containing configuration files for various applications:

```
my-theme/
├── alacritty.toml          # Alacritty terminal config
├── ghostty                 # Ghostty terminal config
├── hyprland.conf          # Hyprland window manager
├── waybar.css             # Waybar status bar styles
├── background.png         # Desktop background
├── neovim.lua            # Neovim configuration
├── tmux.conf             # tmux configuration
└── custom-script.sh*     # Executable script (optional)
```

### Executable Scripts

Themes can include executable scripts that run during theme application:

```bash
#!/bin/bash
# custom-script.sh - receives these arguments:
# $1: script directory path
# $2: theme name
# $3: theme category (light/dark)
# $4: current symlink directory

# Example: reload specific application
if pgrep -x myapp >/dev/null; then
    killall -USR1 myapp  # Send reload signal
fi
```

### User Theme Creation

Create themes in your user directory:

```bash
# Create a new user theme
mkdir -p ~/.config/farv/themes/dark/my-theme
cd ~/.config/farv/themes/dark/my-theme

# Add configuration files
cp ~/.config/alacritty/alacritty.toml ./alacritty.toml
# Edit alacritty.toml with your theme colors...

# Test the theme
farv my-theme
```

### Theme Inheritance

Create partial themes that inherit from system themes:

```bash
# Override just the background for an existing theme
mkdir -p ~/.config/farv/themes/dark/tokyonight-night
cp ~/my-custom-background.png \
  ~/.config/farv/themes/dark/tokyonight-night/background.png

# Now 'tokyonight-night' uses your background but inherits all other files
```

## How It Works

### Theme Application Process

When you run `farv theme-name`:

1. **Theme Discovery**: Searches for theme in user and system directories
2. **File Resolution**: Discovers all unique filenames across the theme
   hierarchy
3. **Symlink Creation**: Creates symlinks in `~/.config/farv/current/`
   pointing to the highest-priority version of each file
4. **Script Execution**: Runs any executable scripts found in the theme
   directories (in priority order)

### Application Integration

Applications are configured to read from the `~/.config/farv/current/`
directory:

```bash
# Example alacritty configuration
alacritty --config-file ~/.config/farv/current/alacritty.toml

# Example in ~/.config/alacritty/alacritty.toml
import = ["~/.config/farv/current/alacritty.toml"]
```

### Supported Applications

Current theme system includes configurations for:

- **Terminals**: Alacritty, Ghostty
- **Window Manager**: Hyprland, Hyprlock
- **Status Bar**: Waybar
- **System**: GTK themes, backgrounds
- **CLI Tools**: bat, btop, fzf, tmux
- **Editors**: Neovim
- **Launchers**: wofi
- **Notifications**: mako

## Examples

### Switching Themes

```bash
# Switch to a light theme
farv rose-pine-dawn

# Switch to a dark theme
farv tokyonight-night

# Interactive selection
farv
# Opens fzf menu with all available themes
```

### Creating a Custom Theme

```bash
# Create directory structure
mkdir -p ~/.config/farv/themes/dark/my-cyberpunk

# Add terminal colors
cat > ~/.config/farv/themes/dark/my-cyberpunk/alacritty.toml << 'EOF'
[colors.primary]
background = '#0a0a0a'
foreground = '#00ff41'

[colors.normal]
black = '#000000'
green = '#00ff41'
cyan = '#00ffff'
# ... more colors
EOF

# Add background
cp ~/Pictures/cyberpunk-wallpaper.png \
  ~/.config/farv/themes/dark/my-cyberpunk/background.png

# Test the theme
farv my-cyberpunk
```

### Theme with Custom Script

```bash
# Create theme with reload script
mkdir -p ~/.config/farv/themes/dark/my-theme

# Create a script that reloads specific applications
cat > ~/.config/farv/themes/dark/my-theme/reload-apps.sh << 'EOF'
#!/bin/bash
# Reload applications after theme switch

# Reload waybar
if pgrep -x waybar >/dev/null; then
    killall waybar
    waybar &
fi

# Notify user
notify-send "Theme Applied" "Switched to $2 theme"
EOF

chmod +x ~/.config/farv/themes/dark/my-theme/reload-apps.sh
```

## Configuration

### User Configuration File

Location: `~/.config/farv/config`

```bash
# Farv user configuration
# HANDLER_TIMEOUT=10
# VERBOSE=true
# DEFAULT_CATEGORY="dark"
```

## Dependencies

### Required
- `bash` (4.0+)
- Standard UNIX utilities (`ln`, `mkdir`, `rm`, etc.)

### Optional
- `fzf` - For interactive theme selection
- `gsettings` - For GTK theme switching
- `hyprctl` - For Hyprland integration
- `jq` - For JSON processing in scripts

## Contributing

1. Themes should follow the established directory structure
2. Include configuration files for as many applications as practical
3. Test themes on both light and dark categories when applicable
4. Document any special requirements or application setup needed

## License

[Add license information]

## See Also

- [r/unixporn](https://reddit.com/r/unixporn) - Community for sharing desktop
  customizations
- [dotfiles repositories](https://dotfiles.github.io/) - More configuration
  examples