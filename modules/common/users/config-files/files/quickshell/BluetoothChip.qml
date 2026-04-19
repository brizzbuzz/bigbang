import QtQuick
import QtQuick.Layouts
import "."

Item {
  id: root

  required property bool enabled
  required property int connectedCount
  required property bool hovered

  implicitWidth: 58
  implicitHeight: 18

  RowLayout {
    anchors.centerIn: parent
    spacing: 6

    Text {
      id: iconLabel
      text: root.connectedCount > 0 ? "󰂯" : "󰂲"
      color: root.connectedCount > 0
        ? Theme.cyan
        : (root.enabled ? Theme.fg : Qt.rgba(139 / 255, 147 / 255, 184 / 255, 0.65))
      font.family: Theme.monoFont
      font.pixelSize: 18
      font.weight: 700
      opacity: root.connectedCount > 0 ? 0.9 : 1

      SequentialAnimation on opacity {
        running: root.connectedCount > 0 && !root.hovered
        loops: Animation.Infinite

        NumberAnimation {
          to: 0.72
          duration: 1500
          easing.type: Easing.InOutSine
        }

        NumberAnimation {
          to: 0.96
          duration: 1500
          easing.type: Easing.InOutSine
        }
      }
    }

    Rectangle {
      visible: root.connectedCount > 1
      radius: 7
      color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.16)
      border.width: 1
      border.color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.28)
      implicitWidth: Math.max(16, badgeText.implicitWidth + 8)
      implicitHeight: 16

      Text {
        id: badgeText
        anchors.centerIn: parent
        text: String(root.connectedCount)
        color: Theme.purple
        font.family: Theme.monoFont
        font.pixelSize: 10
        font.weight: 800
      }
    }
  }
}
