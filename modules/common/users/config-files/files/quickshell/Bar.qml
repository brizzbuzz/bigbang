import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
  id: root

  color: "transparent"
  implicitHeight: 56
  exclusiveZone: 56
  aboveWindows: true
  focusable: false

  anchors {
    top: true
    left: true
    right: true
  }

  margins {
    left: 10
    right: 10
    top: 6
  }

  property string openPopup: ""
  property string currentSubmap: "default"
  property int chipHeight: 36
  property bool wifiEnabled: false
  property string wifiSsid: "offline"

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var battery: UPower.displayDevice
  readonly property var activeToplevel: Hyprland.activeToplevel
  readonly property var btAdapter: Bluetooth.defaultAdapter

  function togglePopup(name) {
    openPopup = openPopup === name ? "" : name
  }

  function run(command) {
    Hyprland.dispatch(`exec ${command}`)
  }

  function refreshNetwork() {
    wifiStateProc.running = false
    wifiSsidProc.running = false
    wifiStateProc.running = true
    wifiSsidProc.running = true
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

  component AccentButton: Rectangle {
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
      onClicked: parent.clicked()
    }
  }

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  Process {
    id: submapProc
    command: ["hyprctl", "submap"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.currentSubmap = text.trim()
    }
  }

  Process {
    id: wifiStateProc
    command: ["bash", "-lc", "nmcli -t -f WIFI g"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
    }
  }

  Process {
    id: wifiSsidProc
    command: ["bash", "-lc", "nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1==\"yes\" {print $2; exit}'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.wifiSsid = text.trim() || (root.wifiEnabled ? "not connected" : "offline")
    }
  }

  Timer {
    interval: 15000
    running: true
    repeat: true
    onTriggered: root.refreshNetwork()
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "submap") {
        root.currentSubmap = event.data || "default"
      }
    }
  }

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"

    RowLayout {
      id: leftRow
      anchors.left: parent.left
      anchors.leftMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      spacing: 12

      Rectangle {
        id: controlCluster
        radius: height / 2
        color: Qt.rgba(17 / 255, 23 / 255, 47 / 255, 0.96)
        border.width: 1
        border.color: Theme.borderBright
        implicitHeight: 48
        implicitWidth: controlRow.implicitWidth + 8
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 1
          height: parent.height / 2
          radius: parent.radius
          color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.03)
        }

        Row {
          id: controlRow
          anchors.fill: parent
          anchors.margins: 4
          spacing: 0

          Rectangle {
            id: notificationButton
            radius: height / 2
            color: notificationHover.hovered ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.28) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.02)
            implicitWidth: notificationLabel.implicitWidth + 22
            implicitHeight: root.chipHeight
            width: implicitWidth
            height: implicitHeight

            Text {
              id: notificationLabel
              anchors.centerIn: parent
              text: "notify"
              color: Theme.cyan
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 800
            }

            HoverHandler { id: notificationHover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                  root.run("swaync-client -d -sw")
                } else {
                  root.run("swaync-client -t -sw")
                }
              }
            }
          }

          Rectangle {
            width: 1
            height: root.chipHeight
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(42 / 255, 51 / 255, 95 / 255, 0.7)
          }

          Rectangle {
            id: audioButton
            radius: 14
            color: audioHover.hovered || root.openPopup === "audio" ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.16) : "transparent"
            implicitWidth: audioLabel.implicitWidth + 32
            implicitHeight: root.chipHeight
            width: implicitWidth
            height: implicitHeight

            Text {
              id: audioLabel
              anchors.centerIn: parent
              text: root.sink?.audio?.muted ? "audio muted" : `audio ${Theme.percent(root.sink?.audio?.volume)}%`
              color: root.openPopup === "audio" ? Theme.cyan : Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
            }

            HoverHandler { id: audioHover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                  root.run("pavucontrol")
                } else if (mouse.button === Qt.MiddleButton && root.sink?.audio) {
                  root.sink.audio.muted = !root.sink.audio.muted
                } else {
                  root.togglePopup("audio")
                }
              }
            }

            WheelHandler {
              onWheel: event => {
                if (!root.sink?.audio) return
                const delta = event.angleDelta.y > 0 ? 0.05 : -0.05
                root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + delta))
              }
            }
          }

          Rectangle {
            id: batteryButton
            radius: 14
            color: batteryHover.hovered || root.openPopup === "battery" ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.12) : "transparent"
            implicitWidth: batteryLabel.implicitWidth + 32
            implicitHeight: root.chipHeight
            width: implicitWidth
            height: implicitHeight

            Text {
              id: batteryLabel
              anchors.centerIn: parent
              text: `power ${Math.round(root.battery?.percentage || 0)}%`
              color: root.openPopup === "battery" ? Theme.yellow : Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
            }

            HoverHandler { id: batteryHover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                  root.run("~/.config/hypr/scripts/power-menu.sh")
                } else {
                  root.togglePopup("battery")
                }
              }
            }
          }

          Rectangle {
            id: clockButton
            radius: height / 2
            color: clockHover.hovered || root.openPopup === "clock" ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.24) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.02)
            implicitWidth: clockLabel.implicitWidth + 34
            implicitHeight: root.chipHeight
            width: implicitWidth
            height: implicitHeight

            Text {
              id: clockLabel
              anchors.centerIn: parent
              text: Theme.formatMinutes(systemClock.date)
              color: root.openPopup === "clock" ? Theme.pink : Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
            }

            HoverHandler { id: clockHover }

            MouseArea {
              anchors.fill: parent
              onClicked: root.togglePopup("clock")
            }
          }
        }
      }
    }

      Rectangle {
        id: workspaceStrip
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      radius: height / 2
      color: Qt.rgba(17 / 255, 23 / 255, 47 / 255, 0.92)
      border.width: 1
      border.color: Qt.rgba(42 / 255, 51 / 255, 95 / 255, 0.95)
        implicitHeight: 44
        implicitWidth: workspaceRow.implicitWidth + 16

      RowLayout {
        id: workspaceRow
        anchors.fill: parent
          anchors.margins: 5
          spacing: 6

        Rectangle {
          visible: root.currentSubmap && root.currentSubmap !== "default"
          radius: 12
          color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.18)
          border.width: 1
          border.color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.35)
          implicitHeight: 32
          implicitWidth: submapText.implicitWidth + 20

          Text {
            id: submapText
            anchors.centerIn: parent
            text: `mode ${root.currentSubmap}`
            color: Theme.yellow
            font.family: Theme.monoFont
            font.pixelSize: 14
            font.weight: 700
          }
        }

        Repeater {
          model: Hyprland.workspaces

          delegate: Rectangle {
            required property var modelData
            readonly property bool shown: root.workspaceVisible(modelData)

            visible: shown
            radius: 14
            color: modelData.focused
              ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.18)
              : modelData.active
                ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.08)
                : hover.hovered
                  ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.16)
                  : "transparent"
            border.width: modelData.focused ? 1 : 0
            border.color: modelData.focused ? Theme.cyan : "transparent"
            implicitHeight: 32
            implicitWidth: wsText.implicitWidth + 24

            Text {
              id: wsText
              anchors.centerIn: parent
              text: root.workspaceDisplay(modelData)
              color: modelData.focused ? Theme.cyan : (modelData.toplevels.count > 0 ? Theme.fg : Theme.fgMuted)
              font.family: Theme.monoFont
              font.pixelSize: 14
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

    RowLayout {
      id: rightRow
      anchors.right: parent.right
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Rectangle {
        id: statusPill
        radius: height / 2
        color: Qt.rgba(17 / 255, 23 / 255, 47 / 255, 0.92)
        border.width: 1
        border.color: Theme.borderBright
        implicitHeight: 44
        implicitWidth: statusRow.implicitWidth + 20

        Row {
          id: statusRow
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          anchors.topMargin: 6
          anchors.bottomMargin: 6
          spacing: 8

          Rectangle {
            id: wifiButton
            radius: 12
            color: wifiHover.hovered ? Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.18) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.02)
            implicitWidth: wifiLabel.implicitWidth + 22
            implicitHeight: 30
            width: implicitWidth
            height: implicitHeight

            Text {
              id: wifiLabel
              anchors.centerIn: parent
              text: root.wifiEnabled ? `wifi ${root.wifiSsid}` : "wifi off"
              color: root.openPopup === "wifi" ? Theme.cyan : (root.wifiEnabled ? Theme.cyan : Theme.fgMuted)
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 800
            }

            HoverHandler { id: wifiHover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                  root.run("nm-connection-editor")
                } else {
                  root.togglePopup("wifi")
                }
              }
            }
          }

          Rectangle {
            id: btButton
            radius: 12
            color: btHover.hovered ? Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.18) : Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.02)
            implicitWidth: btLabel.implicitWidth + 22
            implicitHeight: 30
            width: implicitWidth
            height: implicitHeight

            Text {
              id: btLabel
              anchors.centerIn: parent
              text: root.btAdapter?.enabled ? "bt on" : "bt off"
              color: root.btAdapter?.enabled ? Theme.cyan : Theme.fgMuted
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 800
            }

            HoverHandler { id: btHover }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                  root.run("blueman-manager")
                } else if (root.btAdapter) {
                  root.btAdapter.enabled = !root.btAdapter.enabled
                }
              }
            }
          }
        }
      }
    }
  }

  PopupWindow {
    id: wifiPopup
    visible: root.openPopup === "wifi"
    color: popupBackgroundColor()
    implicitWidth: 360
    implicitHeight: 230

    anchor.item: wifiButton
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
        height: 72
        radius: parent.radius
        color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.08)
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        Text {
          text: "Network"
          color: Theme.cyan
          font.family: Theme.monoFont
          font.pixelSize: 16
          font.weight: 800
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
            spacing: 2

            Text {
              text: root.wifiEnabled ? "Wi-Fi enabled" : "Wi-Fi disabled"
              color: Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
            }

            Text {
              text: root.wifiSsid
              color: Theme.fgMuted
              font.family: Theme.monoFont
              font.pixelSize: 12
              elide: Text.ElideRight
            }
          }
        }

        RowLayout {
          spacing: 10

          AccentButton {
            text: root.wifiEnabled ? "Disable" : "Enable"
            accent: Theme.cyan
            onClicked: {
              root.run(root.wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on")
              root.refreshNetwork()
            }
          }

          AccentButton {
            text: "Connections"
            accent: Theme.purple
            onClicked: root.run("nm-connection-editor")
          }

          AccentButton {
            text: "Advanced"
            accent: Theme.pink
            onClicked: root.run("ghostty -e nmtui")
          }
        }
      }
    }
  }

  PopupWindow {
    id: audioPopup
    visible: root.openPopup === "audio"
    color: popupBackgroundColor()
    implicitWidth: 360
    implicitHeight: 250

    anchor.item: audioButton
    anchor.edges: Edges.Bottom | Edges.Left
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
        height: 68
        radius: parent.radius
        color: Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.08)
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        Text {
          text: "Audio"
          color: Theme.cyan
          font.family: Theme.monoFont
          font.pixelSize: 16
          font.weight: 800
        }

        Text {
          text: root.sink?.audio?.muted ? "Muted" : `Output level ${Theme.percent(root.sink?.audio?.volume)}%`
          color: Theme.fg
          font.family: Theme.monoFont
          font.pixelSize: 14
        }

        Rectangle {
          Layout.fillWidth: true
          radius: 16
          color: Theme.glassSoft
          border.width: 1
          border.color: Theme.border
          implicitHeight: 56

          RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Text {
              text: Theme.audioIcon(root.sink?.audio?.volume || 0, root.sink?.audio?.muted || false, false)
              color: Theme.pink
              font.family: Theme.monoFont
              font.pixelSize: 24
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                text: root.sink?.description || "Default output"
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.monoFont
                font.pixelSize: 13
                font.weight: 700
              }

              Text {
                text: root.sink?.audio?.muted ? "Muted" : `${Theme.percent(root.sink?.audio?.volume)}% volume`
                color: Theme.fgMuted
                font.family: Theme.monoFont
                font.pixelSize: 12
              }
            }
          }
        }

        Slider {
          id: volumeSlider
          from: 0
          to: 1.5
          value: root.sink?.audio?.volume || 0
          Layout.fillWidth: true

          onMoved: {
            if (root.sink?.audio) root.sink.audio.volume = value
          }

          background: Rectangle {
            x: volumeSlider.leftPadding
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            width: volumeSlider.availableWidth
            height: 10
            radius: 999
            color: Qt.rgba(224 / 255, 224 / 255, 224 / 255, 0.12)

            Rectangle {
              width: volumeSlider.visualPosition * parent.width
              height: parent.height
              radius: 999
              color: Theme.cyan
            }
          }

          handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            width: 18
            height: 18
            radius: 999
            color: Theme.fg
            border.width: 2
            border.color: Theme.cyan
          }
        }

        RowLayout {
          spacing: 10

          AccentButton {
            text: root.sink?.audio?.muted ? "Unmute" : "Mute"
            accent: Theme.pink
            onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
          }

          AccentButton {
            text: "Mixer"
            accent: Theme.purple
            onClicked: root.run("pavucontrol")
          }
        }
      }
    }
  }

  PopupWindow {
    id: batteryPopup
    visible: root.openPopup === "battery"
    color: popupBackgroundColor()
    implicitWidth: 340
    implicitHeight: 248

    anchor.item: batteryButton
    anchor.edges: Edges.Bottom | Edges.Left
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
        height: 72
        radius: parent.radius
        color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.07)
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text {
          text: "Power"
          color: Theme.yellow
          font.family: Theme.monoFont
          font.pixelSize: 16
          font.weight: 800
        }

        Text {
          text: `${Theme.batteryIcon(root.battery?.percentage || 0, (root.battery?.timeToFull || 0) > 0)}  ${Math.round(root.battery?.percentage || 0)}%`
          color: Theme.fg
          font.family: Theme.monoFont
          font.pixelSize: 28
          font.weight: 700
        }

        Rectangle {
          Layout.fillWidth: true
          radius: 16
          color: Theme.glassSoft
          border.width: 1
          border.color: Theme.border
          implicitHeight: 72

          RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Rectangle {
              radius: 14
              color: Qt.rgba(255 / 255, 234 / 255, 0 / 255, 0.14)
              implicitWidth: 48
              implicitHeight: 48

              Text {
                anchors.centerIn: parent
                text: Theme.batteryIcon(root.battery?.percentage || 0, (root.battery?.timeToFull || 0) > 0)
                color: Theme.yellow
                font.family: Theme.monoFont
                font.pixelSize: 24
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                text: root.battery?.timeToFull > 0 ? "Charging" : "Battery"
                color: Theme.fg
                font.family: Theme.monoFont
                font.pixelSize: 13
                font.weight: 700
              }

              Text {
                text: root.battery?.timeToFull > 0
                  ? `Full in ${Theme.formatBatteryTime(root.battery.timeToFull)}`
                  : (root.battery?.timeToEmpty > 0 ? `Remaining ${Theme.formatBatteryTime(root.battery.timeToEmpty)}` : "Power source steady")
                color: Theme.fgMuted
                font.family: Theme.monoFont
                font.pixelSize: 12
              }
            }
          }
        }

        Text {
          text: root.battery?.energyRate > 0 ? `Draw ${root.battery.energyRate.toFixed(1)}W` : "Energy rate unavailable"
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 13
        }

        Text {
          text: root.battery?.healthSupported ? `Health ${Math.round(root.battery.healthPercentage)}%` : "Health unavailable"
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 13
        }

        RowLayout {
          spacing: 10

          AccentButton {
            text: "Power"
            accent: Theme.yellow
            onClicked: root.run("~/.config/hypr/scripts/power-menu.sh")
          }

          AccentButton {
            text: "Balanced"
            accent: Theme.purple
            onClicked: root.run("powerprofilesctl set balanced")
          }

          AccentButton {
            text: "Saver"
            accent: Theme.cyan
            onClicked: root.run("powerprofilesctl set power-saver")
          }
        }
      }
    }
  }

  PopupWindow {
    id: clockPopup
    visible: root.openPopup === "clock"
    color: popupBackgroundColor()
    implicitWidth: 360
    implicitHeight: 250

    anchor.item: clockButton
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
          text: Theme.formatMinutes(systemClock.date)
          color: Theme.fg
          font.family: Theme.monoFont
          font.pixelSize: 34
          font.weight: 700
        }

        Text {
          text: Theme.formatLongDate(systemClock.date)
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
              text: Qt.formatDateTime(systemClock.date, "dddd")
              color: Theme.yellow
              font.family: Theme.monoFont
              font.pixelSize: 20
              font.weight: 800
            }

            Text {
              text: Qt.formatDateTime(systemClock.date, "MMMM d, yyyy")
              color: Theme.fg
              font.family: Theme.monoFont
              font.pixelSize: 14
            }
          }
        }
      }
    }
  }
}
