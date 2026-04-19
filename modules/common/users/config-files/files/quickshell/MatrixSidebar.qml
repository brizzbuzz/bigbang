import QtQuick

import "."

Item {
  id: root

  property real density: 1.55
  property real speedMultiplier: 1.75
  property real brightness: 1.08
  property real accentProbability: 0.16
  property bool paused: false

  readonly property int horizontalPadding: 0
  readonly property int verticalPadding: 8
  readonly property int glyphWidth: 8
  readonly property int glyphHeight: 16
  readonly property int columnGap: 0
  readonly property int rowGap: 0
  readonly property int columnStep: glyphWidth + columnGap
  readonly property int rowStep: glyphHeight + rowGap
  readonly property int usableWidth: Math.max(0, width - horizontalPadding * 2)
  readonly property int usableHeight: Math.max(0, height - verticalPadding * 2)
  readonly property int columnCount: Math.max(4, Math.floor(usableWidth / columnStep))
  readonly property int rowCount: Math.max(12, Math.ceil(usableHeight / rowStep) + 2)
  readonly property var glyphSet: [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "A", "B", "C", "D", "E", "F", "H", "K", "M", "N", "R", "T", "X", "Z",
    "a", "c", "e", "h", "k", "m", "n", "r", "t", "x", "z",
    "#", "%", "&", "+", "-", "=", "*", ":", ".", "/", "\\", "|",
    "<", ">", "[", "]", "{", "}", "(", ")", "?", "!", "~", "$"
  ]

  function randomGlyph() {
    return glyphSet[Math.floor(Math.random() * glyphSet.length)]
  }

  function randomInt(minimum, maximum) {
    return minimum + Math.floor(Math.random() * (maximum - minimum + 1))
  }

  function randomColumnAccent() {
    const roll = Math.random()
    if (roll < 0.14) return Theme.pink
    if (roll < 0.42) return Theme.purple
    return Theme.cyan
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"

    Rectangle {
      width: Math.max(12, parent.width * 0.22)
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.08 * root.brightness) }
        GradientStop { position: 0.45; color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.055 * root.brightness) }
        GradientStop { position: 0.8; color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.018 * root.brightness) }
        GradientStop { position: 1.0; color: Qt.rgba(0 / 255, 240 / 255, 255 / 255, 0.0) }
      }
    }

    Rectangle {
      width: Math.max(10, parent.width * 0.14)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.06 * root.brightness) }
        GradientStop { position: 0.5; color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.04 * root.brightness) }
        GradientStop { position: 0.82; color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.012 * root.brightness) }
        GradientStop { position: 1.0; color: Qt.rgba(157 / 255, 78 / 255, 221 / 255, 0.0) }
      }
    }

    Rectangle {
      width: Math.max(8, parent.width * 0.1)
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.042 * root.brightness) }
        GradientStop { position: 0.5; color: Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.026 * root.brightness) }
        GradientStop { position: 0.82; color: Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.008 * root.brightness) }
        GradientStop { position: 1.0; color: Qt.rgba(255 / 255, 0 / 255, 110 / 255, 0.0) }
      }
    }

    Rectangle {
      height: 1
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      color: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.05)
    }
  }

  Repeater {
    model: root.columnCount

    delegate: Item {
      id: column

      required property int index

      x: root.horizontalPadding + index * root.columnStep
      y: root.verticalPadding
      width: root.glyphWidth
      height: root.usableHeight

      property int rows: root.rowCount
      property int streamLength: Math.max(10, Math.round((8 + Math.random() * 12) * root.density))
      property int streamGap: 1 + Math.floor(Math.random() * 4)
      property int headRow: -Math.floor(Math.random() * rows)
      property int tickVariance: 48 + Math.floor(Math.random() * 60)
      property int updateCadence: root.randomInt(1, 3)
      property int updatePhase: root.randomInt(0, 2)
      property int updateCount: root.randomInt(Math.max(2, Math.floor(rows / 6)), Math.max(4, Math.floor(rows / 3)))
      property int burstCadence: root.randomInt(4, 9)
      property int burstPhase: root.randomInt(0, 8)
      property int burstLength: root.randomInt(2, 5)
      property int tickCounter: 0
      property var glyphs: []
      property color accent: root.randomColumnAccent()
      property real accentSeed: Math.random()

      function fillGlyphs() {
        const nextGlyphs = []
        for (let i = 0; i < rows; i += 1) {
          nextGlyphs.push(root.randomGlyph())
        }
        glyphs = nextGlyphs
      }

      function refreshGlyphs(count) {
        const nextGlyphs = glyphs.length === rows ? glyphs.slice(0) : []
        while (nextGlyphs.length < rows) {
          nextGlyphs.push(root.randomGlyph())
        }

        const updates = Math.max(1, count)
        for (let i = 0; i < updates; i += 1) {
          const glyphIndex = Math.floor(Math.random() * rows)
          nextGlyphs[glyphIndex] = root.randomGlyph()
        }

        glyphs = nextGlyphs
      }

      function burstGlyphs() {
        const nextGlyphs = glyphs.length === rows ? glyphs.slice(0) : []
        while (nextGlyphs.length < rows) {
          nextGlyphs.push(root.randomGlyph())
        }

        const burstStart = Math.floor(Math.random() * rows)
        for (let i = 0; i < burstLength && burstStart + i < rows; i += 1) {
          nextGlyphs[burstStart + i] = root.randomGlyph()
        }

        glyphs = nextGlyphs
      }

      function advance() {
        tickCounter += 1
        headRow += 1

        if ((tickCounter + updatePhase) % updateCadence === 0) refreshGlyphs(updateCount)
        if ((tickCounter + burstPhase) % burstCadence === 0) burstGlyphs()

        if (headRow > rows + streamGap) {
          headRow = -streamLength - Math.floor(Math.random() * rows)
          streamLength = Math.max(9, Math.round((7 + Math.random() * 14) * root.density))
          streamGap = 1 + Math.floor(Math.random() * 5)
          tickVariance = 42 + Math.floor(Math.random() * 64)
          updateCadence = root.randomInt(1, 3)
          updatePhase = root.randomInt(0, updateCadence - 1)
          updateCount = root.randomInt(Math.max(2, Math.floor(rows / 6)), Math.max(4, Math.floor(rows / 3)))
          burstCadence = root.randomInt(4, 9)
          burstPhase = root.randomInt(0, burstCadence - 1)
          burstLength = root.randomInt(2, 5)
          if (Math.random() < 0.7) accent = root.randomColumnAccent()
        }
      }

      Component.onCompleted: fillGlyphs()

      Timer {
        interval: Math.max(28, Math.round(column.tickVariance / root.speedMultiplier))
        repeat: true
        running: !root.paused && root.visible
        triggeredOnStart: true
        onTriggered: column.advance()
      }

      Repeater {
        model: column.rows

        delegate: Text {
          required property int index

          x: 0
          y: index * root.rowStep
          width: root.glyphWidth
          height: root.glyphHeight
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: index < column.glyphs.length ? column.glyphs[index] : ""
          color: {
            const distance = column.headRow - index
            if (distance < 0 || distance >= column.streamLength) return Theme.cyan
            if (distance === 0) return Qt.lighter(Theme.cyan, 2.0)
            if (distance === 1) return Qt.lighter(column.accent, 1.55)
            const accentWindow = Math.max(3, Math.round(1 / Math.max(0.01, root.accentProbability)))
            const accentOffset = Math.floor(column.accentSeed * accentWindow)
            return ((index + column.headRow + accentOffset) % accentWindow) === 0 ? column.accent : Theme.cyan
          }
          opacity: {
            const distance = column.headRow - index
            if (distance < 0 || distance >= column.streamLength) return 0
            const normalizedRow = column.rows <= 1 ? 0 : index / (column.rows - 1)
            const fadeProgress = Math.max(0, (normalizedRow - 0.32) / 0.68)
            const bottomFade = Math.max(0, 1 - fadeProgress * fadeProgress)
            if (distance === 0) return Math.min(0.98, 0.98 * root.brightness * bottomFade)
            const fade = 1 - distance / column.streamLength
            const trailOpacity = 0.14 + fade * 0.66
            return Math.min(0.92, trailOpacity * root.brightness * bottomFade)
          }
          font.family: Theme.monoFont
          font.pixelSize: root.glyphHeight - 2
          font.weight: index === column.headRow ? 700 : 500
          style: Text.Normal
          renderType: Text.NativeRendering
        }
      }
    }
  }
}
