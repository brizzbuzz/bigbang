#!/usr/bin/env bash

# ===================================
# Power Menu Script
# ===================================
# Displays power options using Rofi

set -euo pipefail

# Power menu options
LOCK=" Lock"
LOGOUT="󰍃 Logout"
SUSPEND="󰒲 Suspend"
REBOOT="󰜉 Reboot"
SHUTDOWN="󰐥 Shutdown"

# Show menu
CHOSEN=$(echo -e "$LOCK\n$LOGOUT\n$SUSPEND\n$REBOOT\n$SHUTDOWN" | rofi -dmenu -p "Power Menu" -theme-str 'window {width: 300px;}')

# Execute action
case "$CHOSEN" in
    "$LOCK")
        hyprlock
        ;;
    "$LOGOUT")
        hyprctl dispatch exit
        ;;
    "$SUSPEND")
        systemctl suspend
        ;;
    "$REBOOT")
        # Confirm reboot
        CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Reboot?" -theme-str 'window {width: 200px;}')
        if [ "$CONFIRM" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
    "$SHUTDOWN")
        # Confirm shutdown
        CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Shutdown?" -theme-str 'window {width: 200px;}')
        if [ "$CONFIRM" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;
    *)
        # User cancelled
        exit 0
        ;;
esac
