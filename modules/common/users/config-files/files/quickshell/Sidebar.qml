import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
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
      ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, active ? 0.075 : 0.042)
      : Qt.rgba(255 / 255, 255 / 255, 255 / 255, active ? 0.032 : 0.016)
    border.width: 1
    border.color: active
      ? Qt.tint(accent, Qt.rgba(1, 1, 1, buttonMouse.containsMouse ? 0.08 : 0.2))
      : Qt.rgba(68 / 255, 83 / 255, 154 / 255, 0.18)

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

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var battery: UPower.displayDevice
  readonly property int batteryPercent: Theme.batteryPercent(battery?.percentage)
  readonly property var btAdapter: Bluetooth.defaultAdapter
  readonly property var networkDevices: Networking.devices.values
  readonly property var wifiDevice: networkDevices.find(device => device.type === DeviceType.Wifi) || null
  readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
  readonly property var activeWifiNetwork: wifiNetworks.find(network => network.connected) || null

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  Rectangle {
    anchors.fill: parent
    radius: 0
    color: Qt.rgba(9 / 255, 13 / 255, 30 / 255, 0.7)
    border.width: 0

    Rectangle {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 1
      color: Qt.rgba(123 / 255, 137 / 255, 208 / 255, 0.12)
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 8

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 8
          radius: 16
          color: "transparent"
          border.width: 0
        }

        RailIconButton {
          icon: activeWifiNetwork ? "󰤨" : (Networking.wifiEnabled ? "󰤥" : "󰤮")
          accent: Theme.cyan
          active: Networking.wifiEnabled
          onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
          onRightClicked: root.run("nm-connection-editor")
        }

        RailIconButton {
          icon: btAdapter?.enabled ? "󰂯" : "󰂲"
          accent: Theme.purple
          active: !!btAdapter?.enabled
          onClicked: if (btAdapter) btAdapter.enabled = !btAdapter.enabled
          onRightClicked: root.run("blueman-manager")
        }

        RailIconButton {
          icon: sink?.audio?.muted ? "󰝟" : Theme.audioIcon(sink?.audio?.volume || 0, false, false)
          accent: Theme.pink
          active: !(sink?.audio?.muted ?? false)
          onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
          onRightClicked: root.run("pavucontrol")
        }

        RailIconButton {
          icon: Theme.batteryIcon(batteryPercent, (battery?.timeToFull || 0) > 0)
          accent: Theme.yellow
          active: true
          onClicked: root.run("~/.config/hypr/scripts/power-menu.sh")
          onRightClicked: root.run("powerprofilesctl set balanced")
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.rgba(68 / 255, 83 / 255, 154 / 255, 0.12)
      }

      Item { Layout.fillHeight: true }

      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignBottom
        spacing: 0

        RailIconButton {
          icon: "󰐥"
          compact: false
          accent: Theme.yellow
          active: true
          onClicked: root.run("~/.config/hypr/scripts/power-menu.sh")
        }
      }
    }
  }
}
