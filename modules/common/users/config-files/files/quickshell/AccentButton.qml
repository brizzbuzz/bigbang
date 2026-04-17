import QtQuick

Rectangle {
  id: root

  property alias text: label.text
  property color accent: Theme.purple
  signal clicked

  radius: 12
  implicitHeight: 38
  implicitWidth: label.implicitWidth + 28
  color: accentMouse.containsMouse ? Qt.tint(accent, Qt.rgba(1, 1, 1, 0.15)) : Qt.tint(accent, Qt.rgba(0, 0, 0, 0.55))
  border.width: 1
  border.color: Qt.tint(accent, Qt.rgba(1, 1, 1, 0.08))

  Text {
    id: label
    anchors.centerIn: parent
    color: Theme.fg
    font.family: Theme.monoFont
    font.pixelSize: 13
    font.weight: 700
  }

  HoverHandler { id: accentMouse }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
  }
}
