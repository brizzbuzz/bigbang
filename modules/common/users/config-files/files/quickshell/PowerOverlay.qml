import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root

  required property bool open
  required property var runCommand
  required property var dismissOverlay

  color: "transparent"
  visible: open
  focusable: true
  aboveWindows: true
  exclusiveZone: 0

  anchors {
    top: true
    right: true
    bottom: true
    left: true
  }

  HyprlandFocusGrab {
    id: focusGrab
    windows: [root]
    active: root.visible
    onCleared: root.dismissOverlay()
  }

  BackgroundEffect.blurRegion: Region {
    item: backdrop
  }

  function trigger(command) {
    root.dismissOverlay()
    root.runCommand(command)
  }

  function triggerAction(action) {
    switch (action) {
    case "lock":
      trigger("hyprlock")
      break
    case "logout":
      trigger("hyprctl dispatch exit")
      break
    case "suspend":
      trigger("loginctl lock-session && systemctl suspend")
      break
    case "reboot":
      trigger("systemctl reboot")
      break
    case "shutdown":
      trigger("systemctl poweroff")
      break
    }
  }

  Shortcut {
    sequence: "Escape"
    onActivated: root.dismissOverlay()
  }

  Rectangle {
    id: backdrop
    anchors.fill: parent
    color: Qt.rgba(7 / 255, 10 / 255, 22 / 255, 0.62)

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismissOverlay()
    }

    Rectangle {
      id: powerCard
      anchors.centerIn: parent
      width: Math.min(parent.width - 64, 620)
      height: 132
      radius: 28
      color: Qt.rgba(16 / 255, 22 / 255, 43 / 255, 0.9)
      border.width: 1
      border.color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.42)

      MouseArea {
        anchors.fill: parent
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.03)
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 5
          columnSpacing: 12
          rowSpacing: 0

          Repeater {
            model: [
              { label: "Lock", icon: "󰌾", accent: Theme.cyan, command: "lock" },
              { label: "Suspend", icon: "󰒲", accent: Theme.blue, command: "suspend" },
              { label: "Logout", icon: "󰍃", accent: Theme.purple, command: "logout" },
              { label: "Reboot", icon: "󰜉", accent: Theme.pink, command: "reboot" },
              { label: "Shutdown", icon: "󰐥", accent: Theme.yellow, command: "shutdown" }
            ]

            delegate: Rectangle {
              required property var modelData

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.minimumHeight: 88
              radius: 18
              color: buttonMouse.containsMouse
                ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.075)
                : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.03)
              border.width: 1
              border.color: buttonMouse.containsMouse
                ? Qt.tint(modelData.accent, Qt.rgba(1, 1, 1, 0.12))
                : Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.24)

              ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Text {
                  text: modelData.icon
                  color: modelData.accent
                  font.family: Theme.monoFont
                  font.pixelSize: 30
                  font.weight: 700
                }
              }

              HoverHandler { id: buttonMouse }

              MouseArea {
                anchors.fill: parent
                onClicked: root.triggerAction(parent.modelData.command)
              }
            }
          }
        }

      }
    }
  }
}
