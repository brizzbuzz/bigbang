import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property int popupHeight
  required property var battery
  required property int batteryPercent
  required property int batteryHealthPercent
  required property var runCommand

  visible: false
  grabFocus: true
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: popupHeight

  anchor.item: anchorItem
  anchor.edges: Edges.Bottom | Edges.Left
  anchor.gravity: Edges.Bottom | Edges.Right
  anchor.margins.top: 12
  anchor.adjustment: PopupAdjustment.All

  Rectangle {
    anchors.fill: parent
    radius: 22
    color: Theme.glass
    border.width: 1
    border.color: Theme.borderBright

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: 72
      radius: parent.radius
      color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.07)
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 12

      Text {
        text: "Power"
        color: Theme.yellow
        font.family: Theme.monoFont
        font.pixelSize: 16
        font.weight: 800
      }

      Text {
        text: `${Theme.batteryIcon(root.batteryPercent, (root.battery?.timeToFull || 0) > 0)}  ${root.batteryPercent}%`
        color: Theme.fg
        font.family: Theme.monoFont
        font.pixelSize: 28
        font.weight: 700
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassSoft
        border.width: 1
        border.color: Theme.border
        implicitHeight: 72

        RowLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 12

          Rectangle {
            radius: 14
            color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.14)
            implicitWidth: 48
            implicitHeight: 48

            Text {
              anchors.centerIn: parent
              text: Theme.batteryIcon(root.batteryPercent, (root.battery?.timeToFull || 0) > 0)
              color: Theme.yellow
              font.family: Theme.monoFont
              font.pixelSize: 24
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
              text: root.battery?.timeToFull > 0 ? "Charging" : "Battery"
              color: Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
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

      Text {
        text: root.battery?.energyRate > 0 ? `Draw ${root.battery.energyRate.toFixed(1)}W` : "Energy rate unavailable"
        color: Theme.fgMuted
        font.family: Theme.monoFont
        font.pixelSize: 13
      }

      Text {
        text: root.battery?.healthSupported ? `Health ${root.batteryHealthPercent}%` : "Health unavailable"
        color: Theme.fgMuted
        font.family: Theme.monoFont
        font.pixelSize: 13
      }

      RowLayout {
        spacing: 10

        AccentButton {
          text: "Power"
          accent: Theme.yellow
          onClicked: root.runCommand("~/.config/hypr/scripts/power-menu.sh")
        }

        AccentButton {
          text: "Balanced"
          accent: Theme.purple
          onClicked: root.runCommand("powerprofilesctl set balanced")
        }

        AccentButton {
          text: "Saver"
          accent: Theme.cyan
          onClicked: root.runCommand("powerprofilesctl set power-saver")
        }
      }
    }
  }
}
