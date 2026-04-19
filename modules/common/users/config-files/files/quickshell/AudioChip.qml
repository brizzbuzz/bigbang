import QtQuick
import QtQuick.Layouts
import "."

Item {
  id: root

  required property real volume
  required property bool muted
  required property bool hovered

  implicitWidth: 30
  implicitHeight: 18

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 4

    Text {
      text: Theme.audioIcon(root.volume, root.muted, false)
      color: root.hovered ? Theme.pink : (root.muted ? Theme.fgMuted : Theme.fg)
      font.family: Theme.monoFont
      font.pixelSize: 18
      font.weight: 700
      Layout.alignment: Qt.AlignHCenter
    }

    Rectangle {
      radius: 999
      color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.24)
      implicitWidth: 18
      implicitHeight: 3
      Layout.alignment: Qt.AlignHCenter

      Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.muted ? 0 : Math.max(2, parent.width * Math.min(1, Math.max(0, root.volume / 1.5)))
        radius: parent.radius
        color: Theme.pink
      }
    }
  }
}
