{pkgs, ...}: let
  # Previous script definitions remain the same
  batteryScript = pkgs.writeScript "battery.sh" ''
    #!/bin/bash
    BATTERY_INFO="$(pmset -g batt)"
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o "[0-9]*%" | cut -d% -f1)
    CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')

    if [ "$CHARGING" != "" ]; then
      ICON="󰂄"
    elif [ "$PERCENTAGE" -gt 80 ]; then
      ICON="󰁹"
    elif [ "$PERCENTAGE" -gt 60 ]; then
      ICON="󰂀"
    elif [ "$PERCENTAGE" -gt 40 ]; then
      ICON="󰁾"
    elif [ "$PERCENTAGE" -gt 20 ]; then
      ICON="󰁻"
    else
      ICON="󰁺"
    fi

    sketchybar --set "$NAME" icon="$ICON" label="$PERCENTAGE%"
  '';

  wifiScript = pkgs.writeScript "wifi.sh" ''
    #!/bin/bash
    WIFI_INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"

    if [ -z "$WIFI_INFO" ]; then
      ICON="󰤮"
      LABEL="Offline"
    else
      SSID=$(echo "$WIFI_INFO" | grep -o "SSID: .*" | sed 's/^SSID: //')

      if [ -z "$SSID" ]; then
        if ifconfig en0 | grep -q "status: active"; then
          ICON="󰤨"
          LABEL="Hotspot"
        else
          ICON="󰤮"
          LABEL="No WiFi"
        fi
      else
        ICON="󰤨"
        LABEL="$SSID"
      fi
    fi

    sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
  '';

  cpuScript = pkgs.writeScript "cpu.sh" ''
    #!/bin/bash
    CPU_INFO=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
    CPU_PERCENT=$(printf "%.0f" "$CPU_INFO")
    sketchybar --set "$NAME" icon="󰻠" label="$CPU_PERCENT%"
  '';

  memoryScript = pkgs.writeScript "memory.sh" ''
    #!/bin/bash
    MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | grep -o '[0-9]*')
    USED=$((100 - MEMORY))
    sketchybar --set "$NAME" icon="󰍛" label="$USED%"
  '';

  clockScript = pkgs.writeScript "clock.sh" ''
    #!/bin/bash
    sketchybar --set "$NAME" icon="󰥔" label="$(date '+%H:%M')"
  '';

  spaceScript = pkgs.writeScript "space.sh" ''
    #!/bin/bash
    SPACE_ID=$(yabai -m query --spaces --space | jq '.index')
    case $SPACE_ID in
      1) ICON="󰎤";;
      2) ICON="󰎧";;
      3) ICON="󰎪";;
      4) ICON="󰎭";;
      5) ICON="󰎱";;
      *) ICON="󰎳";;
    esac
    sketchybar --set "$NAME" icon="$ICON" label="$SPACE_ID"
  '';
in {
  services.sketchybar = {
    enable = false;
    extraPackages = [pkgs.jq];
    config = ''
      #!/bin/bash

      # Color Definitions - Catppuccin Macchiato
      BLACK="0xff181926"
      WHITE="0xffcad3f5"
      BLUE="0xff8aadf4"
      LAVENDER="0xffb7bdf8"
      SAPPHIRE="0xff7dc4e4"
      GREEN="0xffa6da95"
      RED="0xffed8796"
      PEACH="0xfff5a97f"
      SURFACE="0xff363a4f"

      # Bar Settings
      sketchybar --bar \
        height=45 \
        blur_radius=0 \
        position=top \
        padding_left=10 \
        padding_right=10 \
        margin=10 \
        color=$BLACK \
        shadow=off \
        topmost=off \
        notch_width=188 \
        sticky=on \
        font_smoothing=on \
        y_offset=5

      # Item Defaults
      sketchybar --default \
        background.height=28 \
        background.corner_radius=9 \
        background.border_width=2 \
        background.padding_left=3 \
        background.padding_right=3 \
        icon.font="SFMono Nerd Font:Bold:14.0" \
        icon.color=$WHITE \
        icon.padding_left=8 \
        icon.padding_right=6 \
        label.font="SF Pro:Semibold:13.0" \
        label.color=$WHITE \
        label.padding_left=6 \
        label.padding_right=8

      # Left Items
      sketchybar --add item space left \
        --set space \
        background.color=$SURFACE \
        background.border_color=$BLUE \
        script="${spaceScript}" \
        update_freq=0.5 \
        click_script="yabai -m space --focus $SID"

      # Right Side Items (grouped with padding)
      PADDING=6
      sketchybar --add item.separator sep_right right \
        --set sep_right width=$PADDING

      # Add each item
      sketchybar --add item cpu right \
        --set cpu \
        background.color=$SURFACE \
        background.border_color=$PEACH \
        script="${cpuScript}" \
        update_freq=5
      sketchybar --add item.separator sep1 right \
        --set sep1 width=$PADDING

      sketchybar --add item memory right \
        --set memory \
        background.color=$SURFACE \
        background.border_color=$LAVENDER \
        script="${memoryScript}" \
        update_freq=30
      sketchybar --add item.separator sep2 right \
        --set sep2 width=$PADDING

      sketchybar --add item battery right \
        --set battery \
        background.color=$SURFACE \
        background.border_color=$RED \
        script="${batteryScript}" \
        update_freq=120
      sketchybar --add item.separator sep3 right \
        --set sep3 width=$PADDING

      sketchybar --add item wifi right \
        --set wifi \
        background.color=$SURFACE \
        background.border_color=$SAPPHIRE \
        script="${wifiScript}" \
        update_freq=30
      sketchybar --add item.separator sep4 right \
        --set sep4 width=$PADDING

      sketchybar --add item clock right \
        --set clock \
        background.color=$SURFACE \
        background.border_color=$GREEN \
        script="${clockScript}" \
        update_freq=10

      # Initialize Bar
      sketchybar --update
    '';
  };
}
