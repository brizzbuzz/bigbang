import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property int popupHeight
  required property date currentDate

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
      height: 78
      radius: parent.radius
      color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.08)
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 14

      Text {
        text: "Clock"
        color: Theme.pink
        font.family: Theme.monoFont
        font.pixelSize: 16
        font.weight: 800
      }

      Text {
        text: Theme.formatMinutes(root.currentDate)
        color: Theme.fg
        font.family: Theme.monoFont
        font.pixelSize: 34
        font.weight: 700
      }

      Text {
        text: Theme.formatLongDate(root.currentDate)
        color: Theme.cyan
        font.family: Theme.monoFont
        font.pixelSize: 14
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 18
        color: Qt.rgba(22 / 255, 30 / 255, 63 / 255, 0.72)
        border.width: 1
        border.color: Qt.rgba(42 / 255, 51 / 255, 95 / 255, 0.95)
        implicitHeight: 98

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 8

          Text {
            text: Qt.formatDateTime(root.currentDate, "dddd")
            color: Theme.yellow
            font.family: Theme.monoFont
            font.pixelSize: 20
            font.weight: 800
          }

          Text {
            text: Qt.formatDateTime(root.currentDate, "MMMM d, yyyy")
            color: Theme.fg
            font.family: Theme.monoFont
            font.pixelSize: 14
          }
        }
      }
    }
  }
}
