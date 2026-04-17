import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property int popupHeight
  required property bool wifiEnabled
  required property string wifiSsid
  required property var runCommand

  visible: false
  grabFocus: true
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: popupHeight

  anchor.item: anchorItem
  anchor.edges: Edges.Bottom | Edges.Right
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
      color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.08)
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 14

      Text {
        text: "Network"
        color: Theme.cyan
        font.family: Theme.monoFont
        font.pixelSize: 16
        font.weight: 800
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassSoft
        border.width: 1
        border.color: Theme.border
        implicitHeight: 72

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 2

          Text {
            text: root.wifiEnabled ? "Wi-Fi enabled" : "Wi-Fi disabled"
            color: Theme.fg
            font.family: Theme.monoFont
            font.pixelSize: 13
            font.weight: 700
          }

          Text {
            text: root.wifiSsid
            color: Theme.fgMuted
            font.family: Theme.monoFont
            font.pixelSize: 12
            elide: Text.ElideRight
          }
        }
      }

      RowLayout {
        spacing: 10

        AccentButton {
          text: root.wifiEnabled ? "Disable" : "Enable"
          accent: Theme.cyan
          onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        AccentButton {
          text: "Connections"
          accent: Theme.purple
          onClicked: root.runCommand("nm-connection-editor")
        }

        AccentButton {
          text: "Advanced"
          accent: Theme.pink
          onClicked: root.runCommand("ghostty -e nmtui")
        }
      }
    }
  }
}
