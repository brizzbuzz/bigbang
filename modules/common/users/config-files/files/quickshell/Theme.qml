pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property color bg: "#0a0e27"
  readonly property color bgElevated: "#101632"
  readonly property color bgCard: "#121935"
  readonly property color fg: "#e0e0e0"
  readonly property color fgMuted: "#8a90b8"
  readonly property color pink: "#ff006e"
  readonly property color cyan: "#00f0ff"
  readonly property color purple: "#9d4edd"
  readonly property color yellow: "#ffea00"
  readonly property color success: "#4de29a"
  readonly property color border: "#2a335f"
  readonly property color borderBright: "#44539a"
  readonly property color glass: "#11172f"
  readonly property color glassAlt: "#161e3f"
  readonly property color glassSoft: "#1a2144"
  readonly property color shadow: "#60001f"
  readonly property string monoFont: "JetBrainsMono Nerd Font"

  readonly property var workspaceNames: ({
    1: "web",
    2: "code",
    3: "term",
    4: "chat",
    5: "docs",
    6: "media",
    7: "admin",
    8: "scratch",
    9: "remote",
    10: "temp"
  })

  function workspaceLabel(id) {
    return workspaceNames[id] || String(id)
  }

  function workspaceText(id) {
    return `${id} ${workspaceLabel(id)}`
  }

  function audioIcon(volume, muted, bluetooth) {
    if (muted) return "󰝟"
    if (bluetooth) return "󰂯"
    if (volume >= 0.66) return "󰕾"
    if (volume >= 0.33) return "󰖀"
    return "󰕿"
  }

  function batteryIcon(percentage, charging) {
    if (charging) return "󰂄"
    if (percentage >= 90) return "󰁹"
    if (percentage >= 80) return "󰂂"
    if (percentage >= 70) return "󰂁"
    if (percentage >= 60) return "󰂀"
    if (percentage >= 50) return "󰁿"
    if (percentage >= 40) return "󰁾"
    if (percentage >= 30) return "󰁽"
    if (percentage >= 20) return "󰁼"
    if (percentage >= 10) return "󰁻"
    return "󰁺"
  }

  function batteryPercent(value) {
    if (!value) return 0
    return Math.round(value <= 1 ? value * 100 : value)
  }

  function formatMinutes(date) {
    return Qt.formatDateTime(date, "h:mm AP")
  }

  function formatPreciseTime(date) {
    return Qt.formatDateTime(date, "h:mm:ss.zzz AP")
  }

  function formatLongDate(date) {
    return Qt.formatDateTime(date, "dddd, MMMM d")
  }

  function formatBatteryTime(seconds) {
    if (!seconds || seconds <= 0) return ""
    const totalMinutes = Math.floor(seconds / 60)
    const hours = Math.floor(totalMinutes / 60)
    const minutes = totalMinutes % 60
    if (hours > 0) return `${hours}h ${minutes}m`
    return `${minutes}m`
  }

  function percent(value) {
    return Math.round((value || 0) * 100)
  }
}
