#!/usr/bin/env bash

# Init wallpaper utility
hyprpaper &

# Init Waybar
waybar &

# Init Idle Management Daemon
hypridle &

# Load 1Password in silent mode to activate SSH socket
1password --silent &
