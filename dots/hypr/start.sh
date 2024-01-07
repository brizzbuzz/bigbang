#!/usr/bin/env bash

# Init wallpaper daemon
swww init &

# Set Wallpaper
swww img ~/Pictures/pastel-valley.png &

# Init
waybar &
