import QtQuick
import "."

Item {
  id: root

  required property int batteryPercent
  required property bool charging
  required property bool hovered

  function accentColor() {
    if (root.charging) return Theme.cyan
    if (root.batteryPercent <= 15) return Theme.pink
    if (root.batteryPercent <= 35) return Theme.yellow
    return Theme.blue
  }

  implicitWidth: 28
  implicitHeight: 16

  Rectangle {
    id: shell
    anchors.centerIn: parent
    width: 22
    height: 12
    radius: 3
    color: "transparent"
    border.width: 1
    border.color: Qt.tint(root.accentColor(), Qt.rgba(1, 1, 1, root.hovered ? 0.12 : 0))

    Rectangle {
      anchors.left: parent.left
      anchors.leftMargin: 2
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(2, (parent.width - 4) * Math.max(0, Math.min(1, root.batteryPercent / 100)))
      height: parent.height - 4
      radius: 2
      color: Qt.tint(root.accentColor(), Qt.rgba(1, 1, 1, root.hovered ? 0.1 : 0))
      opacity: root.charging ? 0.95 : 0.88
    }

    Rectangle {
      anchors.left: parent.right
      anchors.leftMargin: 2
      anchors.verticalCenter: parent.verticalCenter
      width: 2
      height: 6
      radius: 1
      color: Qt.tint(root.accentColor(), Qt.rgba(1, 1, 1, root.hovered ? 0.12 : 0))
      opacity: 0.85
    }

    Text {
      visible: root.charging
      anchors.centerIn: parent
      text: "󰂄"
      color: Theme.bg
      font.family: Theme.monoFont
      font.pixelSize: 8
      font.weight: 800
    }
  }
}
