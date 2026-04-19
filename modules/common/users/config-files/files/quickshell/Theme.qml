pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property color bg: "#0a0e27"
  readonly property color bgElevated: "#11162f"
  readonly property color bgCard: "#171d36"
  readonly property color fg: "#d9def2"
  readonly property color fgMuted: "#8b93b8"
  readonly property color pink: "#ff006e"
  readonly property color cyan: "#00f0ff"
  readonly property color purple: "#9d4edd"
  readonly property color yellow: "#ffea00"
  readonly property color blue: "#7aa2f7"
  readonly property color success: "#9ece6a"
  readonly property color border: "#2d355f"
  readonly property color borderBright: "#48538d"
  readonly property color glass: "#10162b"
  readonly property color glassAlt: "#151c35"
  readonly property color glassSoft: "#1a2340"
  readonly property color shadow: "#2a0d33"
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
