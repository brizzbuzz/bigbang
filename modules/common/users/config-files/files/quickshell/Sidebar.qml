import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "."

PanelWindow {
  id: root

  component RailIconButton: Rectangle {
    id: buttonRoot

    property alias icon: iconLabel.text
    property color accent: Theme.cyan
    property bool active: true
    property bool compact: false
    signal clicked
    signal rightClicked

    Layout.fillWidth: true
    implicitHeight: compact ? 42 : 50
    radius: compact ? 16 : 18
    color: buttonMouse.containsMouse
      ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, active ? 0.06 : 0.032)
      : Qt.rgba(255 / 255, 255 / 255, 255 / 255, active ? 0.024 : 0.012)
    border.width: 1
    border.color: active
      ? Qt.tint(accent, Qt.rgba(1, 1, 1, buttonMouse.containsMouse ? 0.08 : 0.2))
      : Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.18)

    Text {
      id: iconLabel
      anchors.centerIn: parent
      color: active ? buttonRoot.accent : Theme.fgMuted
      font.family: Theme.monoFont
      font.pixelSize: compact ? 14 : 18
      font.weight: compact ? 600 : 700
    }

    HoverHandler { id: buttonMouse }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) buttonRoot.rightClicked()
        else buttonRoot.clicked()
      }
    }
  }

  color: "transparent"
  implicitWidth: ShellGeometry.sidebarWidth
  exclusiveZone: ShellGeometry.sidebarWidth
  aboveWindows: true
  focusable: false

  anchors {
    top: true
    left: true
    bottom: true
  }

  margins {
    top: ShellGeometry.sidebarTop
    left: ShellGeometry.sidebarLeft
    bottom: ShellGeometry.sidebarBottom
  }

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  Rectangle {
    anchors.fill: parent
    radius: 0
    color: Qt.rgba(8 / 255, 11 / 255, 24 / 255, 0.74)
    border.width: 0

    Rectangle {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 1
      color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.18)
    }

    MatrixSidebar {
      anchors.fill: parent
      anchors.leftMargin: 0
      anchors.rightMargin: 2
      anchors.topMargin: 4
      anchors.bottomMargin: 4
    }
  }
}
