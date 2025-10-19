#!/bin/bash

# Nord Theme Wallpaper Downloader
# Downloads real arctic/winter photography and Nord-themed wallpapers
# Sources: Unsplash (photography), GitHub (pixel art & themed wallpapers)

set -e

# Create download directory
DOWNLOAD_DIR="$HOME/Pictures/nord-wallpapers"
mkdir -p "$DOWNLOAD_DIR"

echo "Downloading Nord Theme Wallpapers to: $DOWNLOAD_DIR"
echo ""

# Check for wget
if ! command -v wget &> /dev/null; then
    echo "Error: wget is not installed. Please install it first."
    echo "  On Arch: sudo pacman -S wget"
    exit 1
fi

# Function to download arctic/winter photography from Unsplash
# These photos match the Nord color palette (blue, gray, arctic tones)
download_unsplash_arctic() {
    echo "=== Downloading Arctic/Winter Photography from Unsplash ==="
    echo "(Photos matching Nord color palette: blues, grays, cool tones)"
    echo ""

    # Array of Unsplash photo IDs and descriptions
    # Format: "PHOTO_ID|description"
    declare -a photos=(
        # Snow-covered mountains with blue tones
        "iwYm_23zLI0|snow-mountains-blue-landscape"
        "vZlTg_McCDo|blue-mountain-snow"
        "ErC1njs8LCI|iceland-ice-mountain"

        # Norwegian fjords (blue-gray tones)
        "NOASuhk_ME8|fjord-blue-mountains-norway"
        "UKlrAr0Bkdk|fjord-mountain-blue-water"
        "5i2nO_t2Zgo|norwegian-fjord-mountains"
        "nyghAPuJQC8|fjord-mountain-top"

        # Northern lights (aurora borealis)
        "2vVhfhbj5-s|aurora-snow-mountains-starry"
        "TT2ISWFL4iU|northern-lights-purple-blue"
        "LtnPejWDSAY|aurora-snow-mountain-norway"
        "EvKBHBGgaUo|aurora-borealis-iceland-mountain"
        "-3h8OXvt4-0|aurora-snow-mountain-green"
        "XwFJJgOwyhk|aurora-kirkjufell-iceland"
        "IK07OmXSnmU|aurora-water-mountain"

        # Arctic landscapes
        "jG1z5o7NCq4|arctic-mountains-winter"
        "ZCHj_2lJP00|arctic-landscape-blue"
        "4rDCa5hBlCs|arctic-snow-scene"
        "WpQ0xTz3OPE|arctic-ice-landscape"

        # Iceland winter scenes
        "KMn4VEeEPR8|iceland-winter-landscape"
        "5ImfOSibAPI|iceland-blue-mountains"
        "YeO44yVTl20|iceland-winter-scene"

        # Norway winter
        "lFmuWU0tv4M|norway-winter-mountains"
        "4LELawGGUMk|norway-snow-landscape"
        "vbNTwfP_tBo|norway-blue-winter"

        # Minimalist winter/arctic scenes
        "LaKwLAmcnBc|minimalist-snow-mountain"
        "oyXis2kALVE|minimalist-arctic-landscape"
        "jNdwPLn4g0s|minimalist-winter-scene"
    )

    local count=1
    for photo in "${photos[@]}"; do
        IFS='|' read -r photo_id description <<< "$photo"

        echo "[$count/${#photos[@]}] Downloading: ${description}"

        # Unsplash download URL
        local url="https://unsplash.com/photos/${photo_id}/download?force=true"
        local output="$DOWNLOAD_DIR/nord-${description}.jpg"

        if wget -q --max-redirect=5 -O "$output" "$url" 2>/dev/null; then
            # Check if file was actually downloaded (not empty)
            if [ -s "$output" ]; then
                echo "  ✓ Success"
            else
                echo "  ✗ Failed (empty file)"
                rm -f "$output"
            fi
        else
            echo "  ✗ Failed (download error)"
            rm -f "$output"
        fi

        # Be nice to the server
        sleep 1
        ((count++))
    done
    echo ""
}

# Function to download from GitHub nord-backgrounds repository
download_github_nord_backgrounds() {
    echo "=== Downloading from GitHub: dxnst/nord-backgrounds ==="
    echo "(Pixel art and themed Nord wallpapers)"
    echo ""

    local base_url="https://raw.githubusercontent.com/dxnst/nord-backgrounds/main"

    # Try common wallpaper patterns
    # Note: exact filenames may vary, this tries common patterns
    local categories=("pixel" "minimal" "abstract" "landscape")

    for category in "${categories[@]}"; do
        for i in {1..10}; do
            for ext in "png" "jpg"; do
                local file="${category}/${i}.${ext}"
                local alt_file="${category}-${i}.${ext}"

                for try_file in "$file" "$alt_file" "${i}.${ext}"; do
                    local output="$DOWNLOAD_DIR/github-nord-${category}-${i}.${ext}"

                    if wget -q --spider "${base_url}/${try_file}" 2>/dev/null; then
                        echo "  Downloading: ${category}-${i}.${ext}"
                        wget -q -O "$output" "${base_url}/${try_file}" 2>/dev/null && echo "    ✓ Success" || rm -f "$output"
                        break
                    fi
                done
            done
        done
    done
    echo ""
}

# Function to download from linuxdotexe/nordic-wallpapers
download_nordic_wallpapers() {
    echo "=== Downloading from GitHub: linuxdotexe/nordic-wallpapers ==="
    echo "(Community curated Nord-themed wallpapers)"
    echo ""

    local base_url="https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers"

    # Try numbered wallpapers
    for i in {01..30}; do
        for ext in "png" "jpg"; do
            local file="${i}.${ext}"
            local output="$DOWNLOAD_DIR/nordic-${i}.${ext}"

            if wget -q --spider "${base_url}/${file}" 2>/dev/null; then
                echo "  Downloading: wallpaper-${i}.${ext}"
                wget -q -O "$output" "${base_url}/${file}" 2>/dev/null && echo "    ✓ Success" || rm -f "$output"
                break
            fi
        done

        # Don't spam the server
        sleep 0.5
    done
    echo ""
}

# Show manual browsing options
show_manual_options() {
    echo "=== Browse More Wallpapers Manually ==="
    echo ""
    echo "GitHub Repositories (pixel art & themed wallpapers):"
    echo "  • dxnst/nord-backgrounds:      https://github.com/dxnst/nord-backgrounds"
    echo "  • linuxdotexe/nordic-wallpapers: https://github.com/linuxdotexe/nordic-wallpapers"
    echo ""
    echo "Unsplash Collections (arctic photography):"
    echo "  • Arctic Landscapes:   https://unsplash.com/s/photos/arctic-landscape"
    echo "  • Northern Lights:     https://unsplash.com/s/photos/northern-lights"
    echo "  • Norway Winter:       https://unsplash.com/s/photos/norway-winter"
    echo "  • Iceland Winter:      https://unsplash.com/s/photos/iceland-winter"
    echo "  • Norwegian Fjords:    https://unsplash.com/s/photos/norwegian-fjords"
    echo ""
    echo "Wallpaper Sites:"
    echo "  • NordThemeWallpapers: https://nordthemewallpapers.com/"
    echo "  • WallpaperAccess:     https://wallpaperaccess.com/nord-theme"
    echo "  • Wallpaper Flare:     https://www.wallpaperflare.com/search?wallpaper=nord"
    echo ""
    echo "Clone entire repositories:"
    echo "  git clone https://github.com/dxnst/nord-backgrounds.git $DOWNLOAD_DIR/nord-backgrounds"
    echo "  git clone https://github.com/linuxdotexe/nordic-wallpapers.git $DOWNLOAD_DIR/nordic-wallpapers"
    echo ""
}

# Main execution
echo "================================="
echo "Nord Theme Wallpaper Downloader"
echo "================================="
echo ""

# Download from all sources
download_unsplash_arctic
download_github_nord_backgrounds
download_nordic_wallpapers

# Show summary
total_files=$(find "$DOWNLOAD_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | wc -l)
echo "=== Download Complete ==="
echo "Total wallpapers downloaded: $total_files"
echo "Location: $DOWNLOAD_DIR"
echo ""

# Show manual browsing options
show_manual_options

echo "Enjoy your Nord-themed wallpapers!"
