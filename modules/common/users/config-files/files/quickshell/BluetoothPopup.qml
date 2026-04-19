import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "."

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property bool pinnedOpen
  required property var dismissPopup
  required property var adapter
  required property var connectedDevices
  required property var openSettings

  property bool popupHovered: popupHover.hovered

  visible: false
  grabFocus: pinnedOpen
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: connectedDevices.length > 0 ? 252 : 194

  onVisibleChanged: {
    if (!visible && root.pinnedOpen) root.dismissPopup()
  }

  function batteryPercent(device) {
    return `${Math.round(Math.max(0, Math.min(1, Number(device?.battery || 0))) * 100)}%`
  }

  function connectionSummary() {
    if (!root.adapter?.enabled) return "adapter off"
    if (root.adapter?.discovering) return "scanning"
    if (root.connectedDevices.length > 0) return `${root.connectedDevices.length} connected`
    return "ready"
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
          text: "bluetooth"
          color: Theme.purple
          font.family: Theme.monoFont
          font.pixelSize: 14
          font.weight: 800
        }

        Item { Layout.fillWidth: true }

        Text {
          text: root.connectionSummary()
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
        implicitHeight: 66

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 4

          Text {
            text: root.adapter?.name || "no adapter"
            color: Theme.fg
            font.family: Theme.monoFont
            font.pixelSize: 13
            font.weight: 700
          }

          Text {
            text: root.adapter?.enabled
              ? (root.adapter?.discovering ? "discoverable and scanning" : "powered and available")
              : "disabled"
            color: Theme.fgMuted
            font.family: Theme.monoFont
            font.pixelSize: 12
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
          model: root.connectedDevices

          delegate: Rectangle {
            required property var modelData

            Layout.fillWidth: true
            radius: 14
            color: Theme.glassAlt
            border.width: 1
            border.color: Theme.border
            implicitHeight: 58

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              Rectangle {
                radius: 10
                color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.14)
                implicitWidth: 34
                implicitHeight: 34

                IconImage {
                  anchors.centerIn: parent
                  width: 18
                  height: 18
                  source: Quickshell.iconPath(modelData.icon, "bluetooth")
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                  text: modelData.name || modelData.deviceName || "device"
                  color: Theme.fg
                  font.family: Theme.monoFont
                  font.pixelSize: 12
                  font.weight: 700
                  elide: Text.ElideRight
                }

                Text {
                  text: modelData.batteryAvailable ? "battery" : "connected"
                  color: Theme.fgMuted
                  font.family: Theme.monoFont
                  font.pixelSize: 11
                }
              }

              Text {
                text: modelData.batteryAvailable ? root.batteryPercent(modelData) : ""
                visible: modelData.batteryAvailable
                color: Theme.cyan
                font.family: Theme.monoFont
                font.pixelSize: 12
                font.weight: 800
              }
            }
          }
        }

        Rectangle {
          visible: root.connectedDevices.length === 0
          Layout.fillWidth: true
          radius: 14
          color: Theme.glassAlt
          border.width: 1
          border.color: Theme.border
          implicitHeight: 58

          Text {
            anchors.centerIn: parent
            text: root.adapter?.enabled ? "no active devices" : "adapter is disabled"
            color: Theme.fgMuted
            font.family: Theme.monoFont
            font.pixelSize: 12
            font.weight: 700
          }
        }
      }

      Item { Layout.fillHeight: true }

      RowLayout {
        Layout.fillWidth: true

        Item { Layout.fillWidth: true }

        AccentButton {
          text: "settings"
          accent: Theme.purple
          onClicked: root.openSettings()
        }
      }
    }
  }
}
