#!/usr/bin/env bash

# ===================================
# Wallpaper Switcher Script
# ===================================
# Sets a random wallpaper from profile directory

set -euo pipefail

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# Check if directory exists and has images
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Find all image files
WALLPAPERS=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG})

# Check if any wallpapers were found
if [ ${#WALLPAPERS[@]} -eq 0 ] || [ ! -f "${WALLPAPERS[0]}" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Select random wallpaper
RANDOM_WALLPAPER="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"

# Set wallpaper using swww
if command -v swww &> /dev/null; then
    swww img "$RANDOM_WALLPAPER" --transition-type fade --transition-duration 2
    echo "Set wallpaper: $RANDOM_WALLPAPER"
else
    echo "swww not found"
    exit 1
fi
