import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PopupWindow {
  id: root

  required property var anchorItem
  required property color popupColor
  required property int popupWidth
  required property int popupHeight
  required property var sink
  required property var runCommand
  required property var setVolume

  visible: false
  grabFocus: true
  color: popupColor
  implicitWidth: popupWidth
  implicitHeight: popupHeight

  anchor.item: anchorItem
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
        text: root.sink?.audio?.muted ? "Muted" : `Output level ${Theme.percent(volumeSlider.pressed ? volumeSlider.value : root.sink?.audio?.volume)}%`
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
              text: root.sink?.audio?.muted ? "Muted" : `${Theme.percent(volumeSlider.pressed ? volumeSlider.value : root.sink?.audio?.volume)}% volume`
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
        live: true
        value: 0
        Layout.fillWidth: true

        onPressedChanged: {
          if (!pressed) root.setVolume(value)
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
          onClicked: root.runCommand("pavucontrol")
        }
      }

      Connections {
        target: root.sink?.audio || null

        function onVolumeChanged() {
          if (!volumeSlider.pressed) volumeSlider.value = root.sink.audio.volume
        }
      }

      Component.onCompleted: volumeSlider.value = root.sink?.audio?.volume || 0
    }
  }
}
