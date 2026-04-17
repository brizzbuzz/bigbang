#!/usr/bin/env bash

# ===================================
# Screenshot Script for Hyprland
# ===================================
# Usage: screenshot.sh [area|full|window]

set -euo pipefail

# Configuration
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create screenshot directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Function to show notification
notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send -u "$urgency" "Screenshot" "$message"
}

copy_image() {
    local file="$1"
    wl-copy --type image/png < "$file" >/dev/null 2>&1 &
    disown
}

# Function to take screenshot
take_screenshot() {
    local mode="$1"
    local filename="$SCREENSHOT_DIR/screenshot_${mode}_${TIMESTAMP}.png"
    
    case "$mode" in
        area)
            # Screenshot area with selection
            grim -g "$(slurp)" "$filename"
            copy_image "$filename"
            notify "Saved to $filename and copied to clipboard. Swappy opened in background. Press Ctrl+S to save edits."
            # Open in swappy for editing without blocking the script
            swappy -f "$filename" -o "$filename" >/dev/null 2>&1 &
            disown
            ;;
        full)
            # Full screen screenshot
            grim "$filename"
            copy_image "$filename"
            notify "Saved to $filename and copied to clipboard"
            ;;
        window)
            # Active window screenshot
            local window_geometry=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            grim -g "$window_geometry" "$filename"
            copy_image "$filename"
            notify "Saved to $filename and copied to clipboard"
            ;;
        *)
            notify "Invalid mode: $mode\nUsage: screenshot.sh [area|full|window]" "critical"
            exit 1
            ;;
    esac
}

# Main
MODE="${1:-area}"
take_screenshot "$MODE"
