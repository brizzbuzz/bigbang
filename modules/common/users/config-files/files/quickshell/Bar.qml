import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

PanelWindow {
  id: root

  color: "transparent"
  implicitHeight: 50
  exclusiveZone: 50
  aboveWindows: true
  focusable: false

  anchors {
    top: true
    left: true
    right: true
  }

  margins {
    left: ShellGeometry.barLeft
    right: ShellGeometry.barRight
    top: ShellGeometry.barTop
  }

  property string openPopup: ""
  property string currentSubmap: "default"
  property int chipHeight: 32
  property int popupWidth: 400
  property int compactPopupHeight: 276
  property int batteryPopupHeight: 330
  property real pendingVolume: 0
  readonly property int batteryPercent: Theme.batteryPercent(root.battery?.percentage)
  readonly property int batteryHealthPercent: Theme.batteryPercent(root.battery?.healthPercentage)
  readonly property var activeToplevel: Hyprland.activeToplevel
  property date preciseNow: new Date()

  function togglePopup(name) {
    openPopup = openPopup === name ? "" : name
  }

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  function workspaceVisible(workspace) {
    return workspace && workspace.id > 0 && workspace.id <= 10
  }

  function workspaceDisplay(workspace) {
    return Theme.workspaceText(workspace.id)
  }

  function popupBackgroundColor() {
    return Qt.rgba(16 / 255, 22 / 255, 50 / 255, 0.98)
  }

  Process {
    id: submapProc
    command: ["hyprctl", "submap"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.currentSubmap = text.trim()
    }
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "submap") {
        root.currentSubmap = event.data || "default"
      }
    }
  }

  Timer {
    interval: 25
    running: true
    repeat: true
    onTriggered: root.preciseNow = new Date()
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(9 / 255, 13 / 255, 30 / 255, 0.7)

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 1
      color: Qt.rgba(123 / 255, 137 / 255, 208 / 255, 0.16)
    }

    Rectangle {
      id: workspaceStrip
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      radius: height / 2
      color: Qt.rgba(15 / 255, 20 / 255, 42 / 255, 0.82)
      border.width: 1
      border.color: Qt.rgba(62 / 255, 76 / 255, 136 / 255, 0.24)
      implicitHeight: 42
      implicitWidth: workspaceRow.implicitWidth + 16

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.018)
      }

      RowLayout {
        id: workspaceRow
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Rectangle {
          visible: root.currentSubmap && root.currentSubmap !== "default"
          radius: 11
          color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.18)
          border.width: 1
          border.color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.35)
          implicitHeight: 28
          implicitWidth: submapText.implicitWidth + 16

          Text {
            id: submapText
            anchors.centerIn: parent
            text: `mode ${root.currentSubmap}`
            color: Theme.yellow
            font.family: Theme.monoFont
            font.pixelSize: 12
            font.weight: 700
          }
        }

        Repeater {
          model: Hyprland.workspaces

          delegate: Rectangle {
            required property var modelData
            readonly property bool shown: root.workspaceVisible(modelData)

            visible: shown
            radius: 12
            color: modelData.focused
              ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.18)
              : modelData.active
                ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.08)
                : hover.hovered
                  ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.16)
                  : "transparent"
            border.width: modelData.focused ? 1 : 0
            border.color: modelData.focused ? Theme.cyan : "transparent"
            implicitHeight: 28
            implicitWidth: wsText.implicitWidth + 20

            Text {
              id: wsText
              anchors.centerIn: parent
              text: root.workspaceDisplay(modelData)
              color: modelData.focused ? Theme.cyan : (modelData.toplevels.count > 0 ? Theme.fg : Theme.fgMuted)
              font.family: Theme.monoFont
              font.pixelSize: 12
              font.weight: modelData.focused ? 700 : 600
            }

            HoverHandler { id: hover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              onClicked: modelData.activate()
            }
          }
        }
      }
    }

    Rectangle {
      id: clockButton
      anchors.right: parent.right
      anchors.rightMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      radius: 19
      color: Qt.rgba(15 / 255, 20 / 255, 42 / 255, 0.82)
      border.width: 1
      border.color: Qt.rgba(68 / 255, 83 / 255, 154 / 255, 0.24)
      implicitHeight: 42
      implicitWidth: preciseClockRow.implicitWidth + 26

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.018)
      }

      RowLayout {
        id: preciseClockRow
        anchors.centerIn: parent
        spacing: 2

        Text {
          id: preciseClock
          text: Qt.formatDateTime(root.preciseNow, "h:mm:ss")
          color: Theme.cyan
          font.family: Theme.monoFont
          font.pixelSize: 18
          font.weight: 800
        }

        Text {
          text: Qt.formatDateTime(root.preciseNow, ".zzz")
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 12
          font.weight: 700
          Layout.alignment: Qt.AlignBottom
        }

        Text {
          text: Qt.formatDateTime(root.preciseNow, "AP")
          color: Theme.fg
          font.family: Theme.monoFont
          font.pixelSize: 12
          font.weight: 700
          Layout.leftMargin: 4
          Layout.alignment: Qt.AlignBottom
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.togglePopup("clock")
      }
    }
  }

  ClockPopup {
    id: clockPopup
    visible: root.openPopup === "clock"
    anchorItem: clockButton
    popupColor: popupBackgroundColor()
    popupWidth: root.popupWidth
    popupHeight: root.compactPopupHeight
    currentDate: root.preciseNow
  }
}
