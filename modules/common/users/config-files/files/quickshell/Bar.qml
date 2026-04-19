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
  property bool audioPopupPinned: false
  property bool bluetoothPopupPinned: false
  property bool networkPopupPinned: false
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
  readonly property var networkDevices: Networking.devices.values
  readonly property var audioSinks: Pipewire.nodes.values.filter(node => node?.audio && node.isSink && !node.isStream)
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
  readonly property var bluetoothDevices: Bluetooth.devices.values
  readonly property var connectedBluetoothDevices: bluetoothDevices.filter(device => device.connected)
  readonly property var primaryBluetoothDevice: connectedBluetoothDevices.length === 1 ? connectedBluetoothDevices[0] : null
  readonly property var activeNetworkDevice: networkDevices.find(device => device.connected) || null
  readonly property var wifiDevice: networkDevices.find(device => device.type === DeviceType.Wifi) || null
  readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
  readonly property var activeWifiNetwork: wifiNetworks.find(network => network.connected) || null
  readonly property string activeInterfaceName: activeNetworkDevice?.name || wifiDevice?.name || ""
  property date preciseNow: new Date()

  function togglePopup(name) {
    openPopup = openPopup === name ? "" : name
  }

  function toggleNetworkPopup() {
    root.networkPopupPinned = !root.networkPopupPinned
  }

  function toggleAudioPopup() {
    root.audioPopupPinned = !root.audioPopupPinned
  }

  function toggleBluetoothPopup() {
    root.bluetoothPopupPinned = !root.bluetoothPopupPinned
  }

  function dismissNetworkPopup() {
    root.networkPopupPinned = false
  }

  function dismissBluetoothPopup() {
    root.bluetoothPopupPinned = false
  }

  function dismissAudioPopup() {
    root.audioPopupPinned = false
  }

  function openBluetoothSettings() {
    root.run("blueman-manager")
  }

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  function trackedAudioObjects() {
    const objects = []

    if (root.sink) objects.push(root.sink)

    for (const node of root.audioSinks) {
      if (!node) continue
      if (objects.indexOf(node) === -1) objects.push(node)
    }

    return objects
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

  PwObjectTracker {
    objects: root.trackedAudioObjects()
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
      id: bluetoothButton
      anchors.right: networkButton.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      radius: 19
      color: Qt.rgba(17 / 255, 24 / 255, 43 / 255, 0.86)
      border.width: 1
      border.color: bluetoothHover.hovered ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.34) : Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.3)
      implicitHeight: 42
      implicitWidth: 60

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.024)
      }

      BluetoothChip {
        anchors.centerIn: parent
        enabled: !!root.bluetoothAdapter?.enabled
        connectedCount: root.connectedBluetoothDevices.length
        hovered: bluetoothHover.hovered
      }

      HoverHandler { id: bluetoothHover }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
          if (mouse.button === Qt.RightButton) root.openBluetoothSettings()
          else root.toggleBluetoothPopup()
        }
      }
    }

    Rectangle {
      id: audioButton
      anchors.right: clockButton.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      radius: 19
      color: Qt.rgba(17 / 255, 24 / 255, 43 / 255, 0.86)
      border.width: 1
      border.color: audioHover.hovered ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.3) : Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.3)
      implicitHeight: 42
      implicitWidth: 60

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.024)
      }

      AudioChip {
        anchors.centerIn: parent
        volume: root.sink?.audio?.volume || 0
        muted: root.sink?.audio?.muted || false
        hovered: audioHover.hovered
      }

      HoverHandler { id: audioHover }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
          if (mouse.button === Qt.RightButton) root.run("pavucontrol")
          else root.toggleAudioPopup()
        }
      }
    }

    Rectangle {
      id: networkButton
      anchors.right: audioButton.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      radius: 19
      color: Qt.rgba(17 / 255, 24 / 255, 43 / 255, 0.86)
      border.width: 1
      border.color: networkHover.hovered ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.34) : Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.3)
      implicitHeight: 42
      implicitWidth: 76

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2
        radius: parent.radius
        color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.024)
      }

      NetworkStats {
        id: networkStats
        interfaceName: root.activeInterfaceName
      }

      NetworkMiniGraph {
        anchors.centerIn: parent
        downloadHistory: networkStats.downloadHistory
        uploadHistory: networkStats.uploadHistory
        maxRate: networkStats.graphMaxBps
        downloadColor: Theme.cyan
        uploadColor: Theme.pink
        idleColor: Qt.rgba(72 / 255, 83 / 255, 141 / 255, 0.4)
      }

      HoverHandler { id: networkHover }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
          if (mouse.button === Qt.RightButton) root.run("nm-connection-editor")
          else root.toggleNetworkPopup()
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

  NetworkPopup {
    id: networkPopup
    visible: root.networkPopupPinned || networkHover.hovered || popupHovered
    anchorItem: networkButton
    popupColor: popupBackgroundColor()
    popupWidth: 320
    pinnedOpen: root.networkPopupPinned
    dismissPopup: root.dismissNetworkPopup
    activeDevice: root.activeNetworkDevice
    activeWifiNetwork: root.activeWifiNetwork
    interfaceName: root.activeInterfaceName
    downloadBps: networkStats.downloadBps
    uploadBps: networkStats.uploadBps
    peakDownloadBps: networkStats.peakDownloadBps
    peakUploadBps: networkStats.peakUploadBps
  }

  AudioPopup {
    id: audioPopup
    visible: root.audioPopupPinned || audioHover.hovered || popupHovered
    anchorItem: audioButton
    popupColor: popupBackgroundColor()
    popupWidth: 340
    sink: root.sink
    sinks: root.audioSinks
    runCommand: root.run
    pinnedOpen: root.audioPopupPinned
    dismissPopup: root.dismissAudioPopup
  }

  BluetoothPopup {
    id: bluetoothPopup
    visible: root.bluetoothPopupPinned || bluetoothHover.hovered || popupHovered
    anchorItem: bluetoothButton
    popupColor: popupBackgroundColor()
    popupWidth: 320
    pinnedOpen: root.bluetoothPopupPinned
    dismissPopup: root.dismissBluetoothPopup
    adapter: root.bluetoothAdapter
    connectedDevices: root.connectedBluetoothDevices
    openSettings: root.openBluetoothSettings
  }
}
