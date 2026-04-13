#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"

if ! command -v brightnessctl >/dev/null 2>&1; then
  exit 0
fi

if ! brightnessctl -l | grep -q '^rgb:kbd_backlight'; then
  exit 0
fi

case "$action" in
  off)
    brightnessctl -sd rgb:kbd_backlight set 0 >/dev/null
    ;;
  restore)
    brightnessctl -rd rgb:kbd_backlight >/dev/null
    ;;
  *)
    exit 0
    ;;
esac
