# farv

**A friend in rice is a friend that's nice**

farv is a layered theme management system that helps building and switching
between complete desktop themes using a powerful hierarchy concept.

The word "farv" is Danish and means "color" as in an imperative verb - aka. a command.

## The Layer Concept

Think of farv themes like transparent sheets stacked on top of each other.
When you look down through the stack, you see the top-most visible element
at each position. This is exactly how farv resolves your theme files.

### How Layers Work

When you apply a theme like `tokyonight-night`, farv searches through
multiple layers in priority order to find each configuration file:

```
Priority  Layer                           Example Path
   1      User theme-specific             ~/.config/farv/themes/dark/tokyonight-night/
   2      System theme-specific           /usr/share/farv/themes/dark/tokyonight-night/
   3      User category-level             ~/.config/farv/themes/dark/
   4      System category-level           /usr/share/farv/themes/dark/
   5      User global                     ~/.config/farv/themes/
   6      System global                   /usr/share/farv/themes/
```

For each file (like `alacritty.toml`), farv takes the first one it finds,
creating a symbolic link from `~/.config/farv/current/alacritty.toml` to
that file.

### Why This Matters

**Override specific files**: Want to use `tokyonight-night` but with your
own wallpaper? Just put `wallpaper.png` in your user theme directory.
farv will use your wallpaper but inherit everything else from the system
theme.

**Share common settings**: Put files that work across multiple themes
in category-level directories. All your dark themes can share the same
`gtk.sh` script, while light themes use a different one.

**Personal defaults**: Files in your global user directory (`~/.config/farv/themes/`)
act as fallbacks for any theme that doesn't specify them.

### A Practical Example

Let's say you want to customize the popular `rose-pine-dawn` theme:

```
# System provides the base theme
/usr/share/farv/themes/light/rose-pine-dawn/
├── alacritty.toml
├── waybar.css
├── hyprland.conf
└── wallpaper.png

# You add personal touches
~/.config/farv/themes/light/rose-pine-dawn/
├── wallpaper.png          # Your custom wallpaper
└── tmux.conf              # Your tmux config

# You share settings across all light themes
~/.config/farv/themes/light/
└── gtk.sh                 # Light GTK theme script
```

When you run `farv use rose-pine-dawn`, you get:

- Your custom wallpaper (layer 1)
- Your tmux config (layer 1)
- System's alacritty, waybar, hyprland configs (layer 2)
- Your light GTK script (layer 3)

## Quick Start

### List available themes

```bash
farv list
```

### Use a theme

```bash
farv use <tab> # tab completion shows available themes
farv use rose-pine-dawn
```

### Interactive selection (requires fzf)

```bash
farv use
```

### Show current theme

```bash
farv current
```

### Cycle through themes

```bash
farv next      # Next theme alphabetically
farv prev      # Previous theme
farv random    # Random theme
```

## Advanced Features

### Theme Management

```bash
farv new light my-theme        # Create new theme
farv clone rose-pine-dawn      # Clone existing theme
farv pack my-theme.tar.gz      # Package theme for sharing
farv install theme.tar.gz      # Install theme package
```

### Customize Current Theme

You can customize the current theme one file at a time.

```bash
farv customize <tab>  # Show list of files for current theme
```

```bash
farv customize ghostty  # Copy the ghostty file to your override directory
```

### Reload Theme

```bash
farv reload # Reapply current theme
```

### Scripts

Often it will not be enough to just have a file in the theme folder. For
instance, just having a wallpaper.png will not make it so that it will
automatically be set by magic. That magic needs to be implemented in scripts.
Farv comes with a few predefined scripts, and one of those are to set the
wallpaper with `swaybg`. If you use something else, you should create an
executable script in one of your layer folders:

- `~/.config/farv/themes`
- `~/.config/farv/themes/dark`
- `~/.config/farv/themes/light`
- `~/.config/farv/themes/dark/{your-theme}`
- `~/.config/farv/themes/light/{your-theme}`

For something like wallpaper, that will probably be the same for every theme, it
should be put in `~/.config/farv/themes` and then it will be run every time a
new theme is applied. Check `/usr/share/farv/themes/swaybg-wallpaper.sh` for
inspiration.

For something like setting the system appearance to either light or dark mode,
it should be in either:

- `~/.config/farv/themes/dark`, or
- `~/.config/farv/themes/light`

Check the `/usr/share/farv/themes/dark/gtk.sh` and
`/usr/share/farv/themes/light/gtk.sh` for inspiration.

You could have some very specific scripts for a theme that you would like to run
as well. Then just put it in the theme folder, like
`~/.config/farv/themes/dark/my-theme/gtk.sh` and it will be run after applying
`my-theme`.

Remember to make your scripts executable for them to run:

```bash
chmod +x ~/.config/farv/themes/dark/my-theme/gtk.sh
```

At the time of writing this, the included scripts to change wallpaper, reload
tmux configuration etc. is pretty sparse and specific to the tools I use at the
moment. If you write scripts that you think can benefit more than just you,
please consider sharing it in an issue and/or pull request.

## Application Setup

Configure your applications to read from `~/.config/farv/current/`:

**Alacritty** (`~/.config/alacritty/alacritty.toml`):

```toml
import = ["~/.config/farv/current/alacritty.toml"]
```

**tmux** (`~/.config/tmux/tmux.conf`):

```bash
source-file ~/.config/farv/current/tmux.conf
```

**neovim** (`~/.config/nvim/`)
Create a symlink from your plugins directory to the relevant farv file.

```bash
ln -s ~/.config/farv/current/neovim.lua/ ~/.config/nvim/lua/plugins/farv.lua
```

**wofi** (`~/.config/wofi`)
Wofi is started with a reference to a stylesheet. Just reference the stylesheet
in the farv theme.

## Installation

```bash
git clone https://github.com/datamadsen/farv.git
cd farv
sudo ./install.sh
```

**Note:** Installation has only been tested on Arch Linux at the time of writing this, so
check what the install script does and adapt it to your system if necessary.
Here are the cliff notes:

- Platform Detection: Detects whether running on Linux or macOS

- Path Configuration: Sets appropriate installation paths
based on platform (Homebrew paths on macOS, system paths on
Linux)

- Binary Installation: Copies the farv binary to system binary
  directory (/usr/bin on Linux, Homebrew prefix on macOS)

- Theme Installation: Creates system directories and copies
light/dark themes to /usr/share/farv/themes/ (or macOS
equivalent)

- Library Installation: Installs utility libraries to system
share directory

- Shell Completion Setup: Generates and installs tab
completion scripts for bash, zsh, and fish shells

- User Configuration: Creates user config directory at
~/.config/farv/ with default config file

- Permission Handling: Uses sudo on Linux, but not on macOS
when using Homebrew paths

- Validation: Checks that required files (bin/farv, themes/)
exist before proceeding

## Contributing

Contributions are welcome! There isn't really any guidelines - just be yourself.
Contribute via PR or even with a tar file produced with `farv pack`.
