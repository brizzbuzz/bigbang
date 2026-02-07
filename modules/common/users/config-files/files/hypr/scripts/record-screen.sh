#!/usr/bin/env bash

# ===================================
# Screen Recording Toggle Script
# ===================================
# Toggles screen recording on/off

set -euo pipefail

# Configuration
RECORDINGS_DIR="$HOME/Videos/Recordings"
PID_FILE="/tmp/wl-screenrec.pid"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create recordings directory if it doesn't exist
mkdir -p "$RECORDINGS_DIR"

# Function to show notification
notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send -u "$urgency" "Screen Recording" "$message"
}

# Check if recording is active
if [ -f "$PID_FILE" ]; then
    # Stop recording
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill -SIGINT "$PID"
        rm "$PID_FILE"
        notify "Recording stopped and saved"
    else
        rm "$PID_FILE"
        notify "Recording process not found" "critical"
    fi
else
    # Start recording
    OUTPUT_FILE="$RECORDINGS_DIR/recording_${TIMESTAMP}.mp4"
    
    # Select area to record
    GEOMETRY=$(slurp)
    
    if [ -n "$GEOMETRY" ]; then
        # Start recording in background
        wl-screenrec -g "$GEOMETRY" -f "$OUTPUT_FILE" &
        echo $! > "$PID_FILE"
        notify "Recording started\nPress Super+Shift+R to stop"
    else
        notify "Recording cancelled" "low"
    fi
fi
