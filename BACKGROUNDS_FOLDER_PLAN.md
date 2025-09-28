# Backgrounds Folder Implementation Plan

## Current State Analysis

### Current Background Handling
- **Filename Dependence**: Currently backgrounds depend on specific filenames (`wallpaper.jpg`, `wallpaper.png`)
- **Script Locations**: Main wallpaper handling script:
  - `themes/swaybg-wallpaper.sh` - looks for specific wallpaper files
- **Goal**: Replace filename dependence with `backgrounds/current-background` symlink approach

### Current Override Mechanism
farv uses a layered priority system for file resolution in `bin/farv:144-158`:

1. **User theme-specific**: `~/.config/farv/themes/{category}/{theme}/`
2. **System theme-specific**: `/usr/share/farv/themes/{category}/{theme}/`
3. **User category-level**: `~/.config/farv/themes/{category}/`
4. **System category-level**: `/usr/share/farv/themes/{category}/`
5. **User global**: `~/.config/farv/themes/`
6. **System global**: `/usr/share/farv/themes/`

Files are resolved using `resolve_file_path()` and symlinked to `~/.config/farv/current/`

## Proposed Implementation

### 1. Backgrounds Folder Structure

## Key Concept: Source Themes vs Applied Themes

### Source Themes (in `themes/` directory)
**What they contain**: Only background image files, NO symlinks
```
themes/dark/tokyonight-night/backgrounds/
├── wallpaper.jpg     # Background image files only
├── bg1.jpg
└── bg2.png
```

### Applied Themes (in `~/.config/farv/current/`)
**What farv creates**: Symlinks to images + current-background selector
```
~/.config/farv/current/backgrounds/
├── wallpaper.jpg -> /usr/share/farv/themes/dark/tokyonight-night/backgrounds/wallpaper.jpg
├── bg1.jpg -> /usr/share/farv/themes/dark/tokyonight-night/backgrounds/bg1.jpg
├── bg2.png -> /usr/share/farv/themes/dark/tokyonight-night/backgrounds/bg2.png
└── current-background -> wallpaper.jpg    # Created and managed by farv
```

### Complete Structure Overview
```
# SOURCE THEMES (what you create)
themes/
├── dark/
│   └── tokyonight-night/
│       ├── backgrounds/          # Just a folder with images
│       │   ├── wallpaper.jpg     # No symlinks here!
│       │   ├── bg1.jpg
│       │   └── bg2.png
│       └── other-config-files...
└── light/
    └── rose-pine-dawn/
        ├── backgrounds/          # Just a folder with images
        │   ├── main.png          # No symlinks here!
        │   └── alt.jpg
        └── other-config-files...

# APPLIED THEME (what farv creates)
~/.config/farv/current/
├── backgrounds/                  # Managed by farv
│   ├── wallpaper.jpg -> [source] # Symlinks to source files
│   ├── bg1.jpg -> [source]
│   ├── bg2.png -> [source]
│   └── current-background -> wallpaper.jpg  # Farv creates this
├── alacritty.toml -> [source]
└── other-config-files...
```

### 2. Core Changes Required

#### 2.1 Modify `discover_theme_files()` Function
**Location**: `bin/farv:160-180`

**Current Behavior**: Discovers all files in theme hierarchy, excluding executable files
**Required Change**: Add special handling for `backgrounds/` folders

```bash
# In discover_theme_files(), add special case for backgrounds folder
if [ -d "$search_path/backgrounds" ]; then
    # Add backgrounds folder as a discoverable "file"
    if [[ ! " ${files[*]} " =~ "backgrounds" ]]; then
        files+=("backgrounds")
    fi
fi
```

#### 2.2 Modify `resolve_file_path()` Function
**Location**: `bin/farv:144-158`

**Current Behavior**: Resolves individual files using search path priority
**Required Change**: Add special handling for `backgrounds` resolution

```bash
resolve_file_path() {
    local category="$1"
    local theme_name="$2"
    local filename="$3"

    # Special handling for backgrounds folder
    if [ "$filename" = "backgrounds" ]; then
        resolve_backgrounds_path "$category" "$theme_name"
        return $?
    fi

    # Existing file resolution logic...
}
```

#### 2.3 New `resolve_backgrounds_path()` Function
**Location**: New function in `bin/farv`

```bash
resolve_backgrounds_path() {
    local category="$1"
    local theme_name="$2"

    while IFS= read -r search_path; do
        local backgrounds_path="$search_path/backgrounds"
        if [ -d "$backgrounds_path" ]; then
            echo "$backgrounds_path"
            return 0
        fi
    done < <(get_search_paths "$category" "$theme_name")

    return 1
}
```

#### 2.4 Modify `apply_theme()` Function
**Location**: `bin/farv:532-566`

**Current Behavior**: Creates symlinks for all discovered files
**Required Change**: Add special handling for backgrounds folder symlinks

```bash
# In apply_theme(), after the file linking loop:
for filename in "${files[@]}"; do
    if [ "$filename" = "backgrounds" ]; then
        # Handle backgrounds folder specially
        local resolved_backgrounds_path
        resolved_backgrounds_path=$(resolve_backgrounds_path "$theme_category" "$theme_name")
        if [ -n "$resolved_backgrounds_path" ]; then
            # Create backgrounds directory in current theme
            mkdir -p "$FARV_CURRENT_LINK/backgrounds"
            # Symlink all background files
            local first_background=""
            for bg_file in "$resolved_backgrounds_path"/*; do
                if [ -f "$bg_file" ] && [[ ! "$(basename "$bg_file")" == "current-background" ]]; then
                    ln -sf "$bg_file" "$FARV_CURRENT_LINK/backgrounds/$(basename "$bg_file")"
                    # Remember the first background for default selection
                    if [ -z "$first_background" ]; then
                        first_background="$(basename "$bg_file")"
                    fi
                fi
            done
            # Create current-background symlink to first available background
            if [ -n "$first_background" ]; then
                ln -sf "$first_background" "$FARV_CURRENT_LINK/backgrounds/current-background"
            fi
        fi
    else
        # Existing file resolution logic...
        resolved_path=$(resolve_file_path "$theme_category" "$theme_name" "$filename")
        if [ -n "$resolved_path" ]; then
            ln -sf "$resolved_path" "$FARV_CURRENT_LINK/$filename"
        fi
    fi
done
```

### 3. Script Updates

#### 3.1 Update `themes/swaybg-wallpaper.sh`
**Current**: Looks for `wallpaper.jpg/png` directly in theme directory
**New**: Enhanced priority-based background resolution

```bash
#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command swaybg; then
  exit 0
fi

if ! pgrep -x swaybg &>/dev/null; then
  exit 0
fi

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

# Verify wallpaper file exists
if [[ ! -f "$WALLPAPER" ]]; then
  log_action "Wallpaper file does not exist: $WALLPAPER"
  exit 0
fi

# Set wallpaper using setsid approach
setsid swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
```

**Note**: The `bin/handlers/` directory contains unused legacy scripts that are not executed by farv. The actual wallpaper handling is done by `themes/swaybg-wallpaper.sh`.

### 4. New Background Management Commands

#### 4.1 New `farv backgrounds` Command
Add background management subcommands to farv:

```bash
# In main farv script, add new command handling
backgrounds)
    case "${2:-list}" in
        list|ls)
            list_backgrounds
            ;;
        set)
            set_background "$3"
            ;;
        current)
            show_current_background
            ;;
        *)
            echo "Usage: farv backgrounds [list|set <filename>|current]"
            exit 1
            ;;
    esac
    ;;
```

#### 4.2 Background Management Functions

```bash
list_backgrounds() {
    local current_theme_info
    current_theme_info=$(get_current_theme_info)

    if [[ -z "$current_theme_info" ]]; then
        echo "No theme currently active"
        return 1
    fi

    local theme_name theme_category
    theme_name=$(echo "$current_theme_info" | cut -d'|' -f1)
    theme_category=$(echo "$current_theme_info" | cut -d'|' -f2)

    echo "Available backgrounds for $theme_name ($theme_category):"

    # Get current selection
    local current_bg=""
    if [[ -L "$FARV_CURRENT_LINK/backgrounds/current-background" ]]; then
        current_bg=$(basename "$(readlink "$FARV_CURRENT_LINK/backgrounds/current-background")")
    fi

    # List all backgrounds
    if [[ -d "$FARV_CURRENT_LINK/backgrounds" ]]; then
        for bg in "$FARV_CURRENT_LINK/backgrounds"/*.{jpg,jpeg,png}; do
            if [[ -f "$bg" ]]; then
                local bg_name=$(basename "$bg")
                if [[ "$bg_name" == "$current_bg" ]]; then
                    echo "  * $bg_name (current)"
                else
                    echo "    $bg_name"
                fi
            fi
        done
    else
        echo "  No backgrounds folder found"
    fi
}

set_background() {
    local background_name="$1"

    if [[ -z "$background_name" ]]; then
        echo "Error: Background filename required"
        return 1
    fi

    # Check if the background exists in current theme
    if [[ ! -f "$FARV_CURRENT_LINK/backgrounds/$background_name" ]]; then
        echo "Error: Background file '$background_name' not found"
        echo "Available backgrounds:"
        list_backgrounds
        return 1
    fi

    # Update the current-background symlink in current theme
    ln -sf "$background_name" "$FARV_CURRENT_LINK/backgrounds/current-background"

    # Run wallpaper scripts to apply the new background
    echo "Setting background to $background_name..."
    local scripts
    readarray -t scripts < <(find "$FARV_SYSTEM_DIR/themes" "$FARV_USER_THEMES" -name "*wallpaper*" -type f -executable 2>/dev/null)

    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            echo "  - $(basename "$script")"
            "$script"
        fi
    done
}

show_current_background() {
    if [[ -L "$FARV_CURRENT_LINK/backgrounds/current-background" ]]; then
        local current_bg
        current_bg=$(basename "$(readlink "$FARV_CURRENT_LINK/backgrounds/current-background")")
        echo "Current background: $current_bg"
    else
        echo "No background selection found"
    fi
}
```

### 5. Migration Strategy

#### 5.1 Breaking Change Approach
- Themes must be updated to use `backgrounds/` folder structure
- No fallback to legacy filename-based approach
- Clean, consistent implementation without legacy baggage

#### 5.2 Migration Path
1. **Phase 1**: Implement core backgrounds folder support (current-background only)
2. **Phase 2**: Convert all existing themes to use backgrounds folders
3. **Phase 3**: Add background management commands
4. **Phase 4**: Update documentation and examples

#### 5.3 Required Theme Updates

### What Needs to Change in Source Themes

**ONLY** move wallpaper files from theme root to `backgrounds/` folder:

```bash
# Convert themes with wallpaper files
for theme_dir in themes/*/*/; do
  if [[ -f "$theme_dir/wallpaper.jpg" ]] || [[ -f "$theme_dir/wallpaper.png" ]]; then
    mkdir -p "$theme_dir/backgrounds"
    # Move wallpaper file to backgrounds folder
    if [[ -f "$theme_dir/wallpaper.jpg" ]]; then
      mv "$theme_dir/wallpaper.jpg" "$theme_dir/backgrounds/"
    elif [[ -f "$theme_dir/wallpaper.png" ]]; then
      mv "$theme_dir/wallpaper.png" "$theme_dir/backgrounds/"
    fi
  fi
done
```

### Before and After Examples

**BEFORE (legacy structure)**:
```
themes/dark/tokyonight-night/
├── wallpaper.jpg          # ← Remove from here
├── alacritty.toml
├── tmux.conf
└── hyprland.conf
```

**AFTER (backgrounds folder structure)**:
```
themes/dark/tokyonight-night/
├── backgrounds/
│   └── wallpaper.jpg      # ← Move to here (NO symlinks!)
├── alacritty.toml
├── tmux.conf
└── hyprland.conf
```

### What farv Does Automatically

When you run `farv use tokyonight-night`, farv creates:

```
~/.config/farv/current/
├── backgrounds/
│   ├── wallpaper.jpg -> /usr/share/farv/themes/dark/tokyonight-night/backgrounds/wallpaper.jpg
│   └── current-background -> wallpaper.jpg    # ← farv creates this
├── alacritty.toml -> /usr/share/farv/themes/dark/tokyonight-night/alacritty.toml
├── tmux.conf -> /usr/share/farv/themes/dark/tokyonight-night/tmux.conf
└── hyprland.conf -> /usr/share/farv/themes/dark/tokyonight-night/hyprland.conf
```

### Important Notes

- **Source themes**: Never contain `current-background` symlinks
- **Applied themes**: farv manages all symlinks including `current-background`
- **Background switching**: Only updates `current-background` in `~/.config/farv/current/backgrounds/`

### 6. Benefits

1. **Multiple Backgrounds**: Each theme can provide multiple background options
2. **Easy Switching**: Users can switch backgrounds within a theme using `farv backgrounds set`
3. **Override Support**: Full hierarchy support - users can override system theme backgrounds
4. **Clean Implementation**: No legacy fallback code, simple and maintainable
5. **Consistent Approach**: All themes use the same backgrounds/current-background structure
6. **Extensible**: Foundation for future enhancements like random background rotation

### 7. Implementation Order

1. **Core Functions**: Add resolve_backgrounds_path and modify core functions
2. **Theme Application**: Update apply_theme to handle backgrounds folders
3. **Script Updates**: Update wallpaper handling scripts
4. **Command Interface**: Add farv backgrounds commands
5. **Documentation**: Update README and examples

This plan provides a comprehensive path to implement backgrounds folder support using a clean, current-background symlink approach that follows farv's existing architectural patterns.