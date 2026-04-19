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
  readonly property var primaryWorkspaceIds: [1, 2, 3]
  property date preciseNow: new Date()

  function togglePopup(name) {
    openPopup = openPopup === name ? "" : name
  }

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  function workspaceVisible(workspace) {
    if (!workspace || workspace.id <= 0) return false
    return root.primaryWorkspaceIds.indexOf(workspace.id) !== -1 || root.workspaceClients(workspace.id).length > 0
  }

  function formatWorkspaceToken(value) {
    return String(value || "")
      .replace(/^com\./, "")
      .replace(/[-_.]/g, " ")
      .replace(/\s+/g, " ")
      .trim()
      .toLowerCase()
  }

  function workspaceClientLabel(toplevel) {
    const rawApp = root.formatWorkspaceToken(toplevel?.appId || toplevel?.class)
    if (Theme.workspaceAppNames[rawApp]) return Theme.workspaceAppNames[rawApp]
    if (rawApp) return rawApp

    const rawTitle = root.formatWorkspaceToken(toplevel?.title)
    if (Theme.workspaceAppNames[rawTitle]) return Theme.workspaceAppNames[rawTitle]
    return rawTitle || "window"
  }

  function workspaceClients(workspaceId) {
    const clients = Hyprland.toplevels.values || []
    return clients.filter(client => client?.workspace?.id === workspaceId)
  }

  function workspaceClientLabels(workspace) {
    if (!workspace) return []

    const labels = []
    const clients = root.workspaceClients(workspace.id)

    for (const client of clients) {
      const label = root.workspaceClientLabel(client)
      if (label && labels.indexOf(label) === -1) labels.push(label)
    }

    return labels
  }

  function workspaceDisplay(workspace) {
    if (root.primaryWorkspaceIds.indexOf(workspace.id) !== -1) {
      return `${workspace.id} ${Theme.workspaceLabel(workspace.id)}`
    }

    const labels = root.workspaceClientLabels(workspace)
    if (!labels.length) return String(workspace.id)

    const text = `${workspace.id} ${labels.join(" + ")}`
    return text.length > 32 ? `${text.slice(0, 31)}…` : text
  }

  function popupBackgroundColor() {
    return Qt.rgba(17 / 255, 22 / 255, 47 / 255, 0.98)
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
    color: Qt.rgba(8 / 255, 11 / 255, 24 / 255, 0.74)

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 1
      color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.22)
    }

    Rectangle {
      id: workspaceStrip
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      radius: height / 2
      color: Qt.rgba(17 / 255, 24 / 255, 43 / 255, 0.86)
      border.width: 1
      border.color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.3)
      implicitHeight: 42
      implicitWidth: workspaceRow.implicitWidth + 16

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.024)
      }

      RowLayout {
        id: workspaceRow
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Rectangle {
          visible: root.currentSubmap && root.currentSubmap !== "default"
          radius: 11
          color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.12)
          border.width: 1
          border.color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.28)
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
              ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.14)
              : modelData.active
                ? Qt.rgba(122 / 255, 162 / 255, 247 / 255, 0.1)
                : hover.hovered
                  ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.12)
                  : "transparent"
            border.width: modelData.focused ? 1 : 0
            border.color: modelData.focused ? Theme.cyan : "transparent"
            implicitHeight: 28
            implicitWidth: Math.min(260, wsText.implicitWidth + 20)

            Text {
              id: wsText
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.margins: 10
              text: root.workspaceDisplay(modelData)
              color: modelData.focused ? Theme.cyan : (root.workspaceClients(modelData.id).length > 0 ? Theme.fg : Theme.fgMuted)
              font.family: Theme.monoFont
              font.pixelSize: 12
              font.weight: modelData.focused ? 700 : 600
              horizontalAlignment: Text.AlignHCenter
              elide: Text.ElideRight
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
      color: Qt.rgba(17 / 255, 24 / 255, 43 / 255, 0.86)
      border.width: 1
      border.color: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.3)
      implicitHeight: 42
      implicitWidth: preciseClockRow.implicitWidth + 26

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.024)
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
