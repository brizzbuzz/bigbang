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
CHOSEN=$(echo -e "$LOCK\n$LOGOUT\n$SUSPEND\n$REBOOT\n$SHUTDOWN" | walker --dmenu --prompt "Power Menu")

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
        CONFIRM=$(echo -e "Yes\nNo" | walker --dmenu --prompt "Reboot?")
        if [ "$CONFIRM" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
    "$SHUTDOWN")
        # Confirm shutdown
        CONFIRM=$(echo -e "Yes\nNo" | walker --dmenu --prompt "Shutdown?")
        if [ "$CONFIRM" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;
    *)
        # User cancelled
        exit 0
        ;;
esac
