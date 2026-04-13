#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"

if ! command -v brightnessctl >/dev/null 2>&1; then
  exit 0
fi

case "$action" in
  dim)
    if brightnessctl -l | grep -q '^backlight'; then
      brightnessctl -s set 10 >/dev/null
    fi
    ;;
  restore)
    if brightnessctl -l | grep -q '^backlight'; then
      brightnessctl -r >/dev/null
    fi
    ;;
  *)
    exit 0
    ;;
esac
