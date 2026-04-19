import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "."

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property var sink
  required property var sinks
  required property var runCommand
  required property bool pinnedOpen
  required property var dismissPopup

  visible: false
  grabFocus: pinnedOpen
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: 360

  property bool popupHovered: popupHover.hovered

  function sinkLabel(sink) {
    return sink?.description || sink?.nickname || sink?.name || "output"
  }

  function isCurrentSink(candidate) {
    return candidate && root.sink && candidate.id === root.sink.id
  }

  function availableAlternateSinks() {
    return (root.sinks || []).filter(candidate => candidate && !root.isCurrentSink(candidate))
  }

  function currentVolume() {
    return root.sink?.audio?.volume || 0
  }

  function setVolume(nextVolume) {
    if (!root.sink?.audio) return
    root.sink.audio.volume = Math.max(0, Math.min(1.0, nextVolume))
  }

  function nudgeVolume(delta) {
    root.setVolume(root.currentVolume() + delta)
  }

  onVisibleChanged: {
    if (!visible && root.pinnedOpen) root.dismissPopup()
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
          text: "audio"
          color: Theme.pink
          font.family: Theme.monoFont
          font.pixelSize: 14
          font.weight: 800
        }

        Item { Layout.fillWidth: true }
      }

      Rectangle {
        Layout.fillWidth: true
        radius: 16
        color: Theme.glassSoft
        border.width: 1
        border.color: Theme.border
        implicitHeight: 64

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
              text: root.sinkLabel(root.sink)
              color: Theme.fg
              elide: Text.ElideRight
              font.family: Theme.monoFont
              font.pixelSize: 13
              font.weight: 700
            }

            Text {
              text: root.sink?.audio?.muted ? "Muted" : "Default output"
              color: Theme.fgMuted
              font.family: Theme.monoFont
              font.pixelSize: 12
            }
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 10
          radius: 999
          color: Qt.rgba(139 / 255, 147 / 255, 184 / 255, 0.18)

          Rectangle {
            width: parent.width * Math.min(1, Math.max(0, root.currentVolume()))
            height: parent.height
            radius: 999
            color: Theme.cyan
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          AccentButton {
            text: "−"
            accent: Theme.purple
            onClicked: root.nudgeVolume(-0.05)
          }

          Item { Layout.fillWidth: true }

          Text {
            text: root.sink?.audio?.muted ? "muted" : `${Theme.percent(root.currentVolume())}`
            color: Theme.fg
            font.family: Theme.monoFont
            font.pixelSize: 12
            font.weight: 700
            Layout.alignment: Qt.AlignVCenter
          }

          Item { Layout.fillWidth: true }

          AccentButton {
            text: "+"
            accent: Theme.cyan
            onClicked: root.nudgeVolume(0.05)
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
          text: root.availableAlternateSinks().length > 0 ? "outputs" : "no other outputs"
          color: Theme.fgMuted
          font.family: Theme.monoFont
          font.pixelSize: 11
          font.weight: 700
        }

        Repeater {
          model: root.availableAlternateSinks()

          delegate: Rectangle {
            required property var modelData

            Layout.fillWidth: true
            radius: 14
            color: root.isCurrentSink(modelData)
              ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.1)
              : rowHover.hovered
                ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.05)
                : Theme.glassAlt
            border.width: 1
            border.color: root.isCurrentSink(modelData)
              ? Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.3)
              : Theme.border
            implicitHeight: 48

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              Text {
                text: "󰕾"
                color: Theme.fgMuted
                font.family: Theme.monoFont
                font.pixelSize: 15
              }

              Text {
                Layout.fillWidth: true
                text: root.sinkLabel(modelData)
                color: Theme.fg
                elide: Text.ElideRight
                font.family: Theme.monoFont
                font.pixelSize: 12
                font.weight: 600
              }
            }

            HoverHandler { id: rowHover }

            MouseArea {
              anchors.fill: parent
              onClicked: Pipewire.preferredDefaultAudioSink = parent.modelData
            }
          }
        }

        Rectangle {
          visible: root.availableAlternateSinks().length === 0
          Layout.fillWidth: true
          radius: 14
          color: Theme.glassAlt
          border.width: 1
          border.color: Theme.border
          implicitHeight: 44

          Text {
            anchors.centerIn: parent
            text: "current output only"
            color: Theme.fgMuted
            font.family: Theme.monoFont
            font.pixelSize: 12
            font.weight: 700
          }
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
          onClicked: root.runCommand("pavucontrol")
        }
      }

      Connections {
        target: root.sink?.audio || null

        function onMutedChanged() {
          // Keep bindings reactive when mute state changes.
        }
      }
    }
  }
}
