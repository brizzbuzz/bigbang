import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property var battery
  required property var healthBattery
  required property int batteryPercent
  required property var runCommand
  required property bool pinnedOpen
  required property var dismissPopup
  property bool popupHovered: popupHover.hovered

  visible: false
  grabFocus: pinnedOpen
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: 348

  function batteryAccent() {
    if (root.battery?.timeToFull > 0) return Theme.cyan
    if (root.batteryPercent <= 15) return Theme.pink
    if (root.batteryPercent <= 35) return Theme.yellow
    return Theme.blue
  }

  function batteryStateLabel() {
    if (root.battery?.timeToFull > 0) return "plugged in"
    if (root.battery?.timeToEmpty > 0) return "on battery"
    return "battery"
  }

  function changeRateWatts() {
    return Math.abs(Number(root.battery?.changeRate || root.battery?.energyRate || 0))
  }

  function healthPercent() {
    return Theme.batteryPercent(root.healthBattery?.healthPercentage)
  }

  function hasDrawInfo() {
    return root.changeRateWatts() > 0
  }

  function hasHealthInfo() {
    return !!root.healthBattery?.healthSupported && root.healthPercent() > 0
  }

  function timeMetricSeconds() {
    return root.battery?.timeToFull > 0
      ? Number(root.battery.timeToFull || 0)
      : Number(root.battery?.timeToEmpty || 0)
  }

  function timeMetricLabel() {
    return root.battery?.timeToFull > 0 ? "time to full" : "remaining"
  }

  function timeMetricText() {
    return root.timeMetricSeconds() > 0 ? Theme.formatBatteryTime(root.timeMetricSeconds()) : "steady"
  }

  function metricBarRatio(kind) {
    if (kind === "charge") return Math.max(0, Math.min(1, root.batteryPercent / 100))
    if (kind === "time") return Math.max(0, Math.min(1, root.timeMetricSeconds() / (6 * 60 * 60)))
    if (kind === "draw") return Math.max(0, Math.min(1, root.changeRateWatts() / 30))
    return 0
  }

  onVisibleChanged: {
    if (!visible && root.pinnedOpen) root.dismissPopup()
  }

  anchor.item: anchorItem
  anchor.rect.x: anchorItem.width / 2 - width / 2
  anchor.rect.y: anchorItem.height + 12
  anchor.adjustment: PopupAdjustment.All

  Rectangle {
    anchors.fill: parent
    radius: 22
    color: Theme.glass
    border.width: 1
    border.color: Theme.borderBright

    HoverHandler { id: popupHover }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 12

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "battery"
          color: root.batteryAccent()
          font.family: Theme.monoFont
          font.pixelSize: 14
          font.weight: 800
        }

        Item { Layout.fillWidth: true }

        Text {
          text: root.batteryStateLabel()
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 12
          font.weight: 700
        }
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassSoft
        border.width: 1
        border.color: Theme.border
        implicitHeight: 84

        RowLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 12

          Rectangle {
            radius: 14
            color: Qt.rgba(122 / 255, 162 / 255, 247 / 255, 0.12)
            implicitWidth: 48
            implicitHeight: 48

            Text {
              anchors.centerIn: parent
              text: Theme.batteryIcon(root.batteryPercent, (root.battery?.timeToFull || 0) > 0)
              color: root.batteryAccent()
              font.family: Theme.monoFont
              font.pixelSize: 24
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
              text: `${root.batteryPercent}%`
              color: Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 18
              font.weight: 800
            }

            Text {
              text: root.battery?.timeToFull > 0
                ? `Full in ${Theme.formatBatteryTime(root.battery.timeToFull)}`
                : (root.battery?.timeToEmpty > 0 ? `Remaining ${Theme.formatBatteryTime(root.battery.timeToEmpty)}` : "Power source steady")
              color: Theme.fgMuted
              font.family: Theme.monoFont
              font.pixelSize: 12
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassAlt
        border.width: 1
        border.color: Theme.border
        implicitHeight: 190

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10

          Repeater {
            model: [
              { label: "charge", value: `${root.batteryPercent}%`, ratio: root.metricBarRatio("charge"), color: root.batteryAccent() },
              { label: root.timeMetricLabel(), value: root.timeMetricText(), ratio: root.metricBarRatio("time"), color: Theme.blue },
              { label: "draw", value: root.hasDrawInfo() ? `${root.changeRateWatts().toFixed(1)}W` : "steady", ratio: root.metricBarRatio("draw"), color: Theme.yellow },
              { label: "health", value: root.hasHealthInfo() ? `${root.healthPercent()}%` : "n/a", ratio: root.hasHealthInfo() ? Math.max(0, Math.min(1, root.healthPercent() / 100)) : 0, color: Theme.purple }
            ]

            delegate: ColumnLayout {
              required property var modelData

              Layout.fillWidth: true
              spacing: 4

              RowLayout {
                Layout.fillWidth: true

                Text {
                  text: modelData.label
                  color: Theme.fgMuted
                  font.family: Theme.monoFont
                  font.pixelSize: 11
                  font.weight: 700
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: modelData.value
                  color: Theme.fg
                  font.family: Theme.monoFont
                  font.pixelSize: 11
                  font.weight: 700
                }
              }

              Rectangle {
                Layout.fillWidth: true
                implicitHeight: 6
                radius: 999
                color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.22)

                Rectangle {
                  width: Math.max(3, parent.width * modelData.ratio)
                  height: parent.height
                  radius: parent.radius
                  color: modelData.color
                }
              }
            }
          }
        }
      }
    }
  }
}
