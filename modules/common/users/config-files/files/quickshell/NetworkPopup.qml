import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property bool pinnedOpen
  required property var dismissPopup
  required property var activeDevice
  required property var activeWifiNetwork
  required property string interfaceName
  required property real downloadBps
  required property real uploadBps
  required property real peakDownloadBps
  required property real peakUploadBps

  property bool popupHovered: popupHover.hovered

  visible: false
  grabFocus: pinnedOpen
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: 272

  onVisibleChanged: {
    if (!visible && root.pinnedOpen) root.dismissPopup()
  }

  function formatRate(rate) {
    const units = ["B/s", "KB/s", "MB/s", "GB/s"]
    let value = Math.max(0, Number(rate || 0))
    let unitIndex = 0

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024
      unitIndex++
    }

    const digits = value >= 100 ? 0 : value >= 10 ? 1 : 2
    return `${value.toFixed(digits)} ${units[unitIndex]}`
  }

  function percent(value) {
    return `${Math.round(Math.max(0, Math.min(1, Number(value || 0))) * 100)}%`
  }

  function networkKind() {
    if (root.activeDevice?.type === DeviceType.Wifi) return "wifi"
    if (root.activeDevice?.connected) return "ethernet"
    return "offline"
  }

  anchor.item: anchorItem
  anchor.rect.x: anchorItem.width / 2 - width / 2
  anchor.rect.y: anchorItem.height + 12
  anchor.adjustment: PopupAdjustment.All

  Rectangle {
    anchors.fill: parent
    radius: 22
    color: Theme.glass
    border.width: 1
    border.color: Theme.borderBright

    HoverHandler { id: popupHover }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 12

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: root.networkKind()
          color: Theme.cyan
          font.family: Theme.monoFont
          font.pixelSize: 14
          font.weight: 800
        }

        Item { Layout.fillWidth: true }

        Text {
          text: root.interfaceName || "no-link"
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 12
          font.weight: 700
        }
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassSoft
        border.width: 1
        border.color: Theme.border
        implicitHeight: 72

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 4

          Text {
            text: root.activeWifiNetwork?.name || (root.activeDevice?.connected ? "wired connection" : "not connected")
            color: Theme.fg
            font.family: Theme.monoFont
            font.pixelSize: 13
            font.weight: 700
            elide: Text.ElideRight
          }

          Text {
            text: root.activeWifiNetwork ? `signal ${root.percent(root.activeWifiNetwork.signalStrength)}` : (root.activeDevice?.connected ? "link active" : "waiting for network")
            color: Theme.fgMuted
            font.family: Theme.monoFont
            font.pixelSize: 12
          }
        }
      }

      GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 12
        rowSpacing: 10

        Repeater {
          model: [
            { label: "down", value: root.formatRate(root.downloadBps), accent: Theme.cyan },
            { label: "up", value: root.formatRate(root.uploadBps), accent: Theme.pink },
            { label: "down peak", value: root.formatRate(root.peakDownloadBps), accent: Theme.blue },
            { label: "up peak", value: root.formatRate(root.peakUploadBps), accent: Theme.purple }
          ]

          delegate: Rectangle {
            required property var modelData

            Layout.fillWidth: true
            radius: 14
            color: Theme.glassAlt
            border.width: 1
            border.color: Theme.border
            implicitHeight: 58

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 2

              Text {
                text: modelData.label
                color: Theme.fgMuted
                font.family: Theme.monoFont
                font.pixelSize: 11
                font.weight: 700
              }

              Text {
                text: modelData.value
                color: modelData.accent
                font.family: Theme.monoFont
                font.pixelSize: 13
                font.weight: 800
              }
            }
          }
        }
      }
    }
  }
}
