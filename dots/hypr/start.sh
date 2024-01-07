#!/usr/bin/env bash

# Init wallpaper daemon
swww init &

# Set Wallpaper
swww img ~/Pictures/pastel-valley.png &

# Init Waybar
waybar &

# Load 1Password in silent mode to activate SSH socket
1password --silent &
