import QtQuick

Item {
  id: root

  required property var downloadHistory
  required property var uploadHistory
  required property real maxRate
  required property color downloadColor
  required property color uploadColor
  required property color idleColor

  implicitWidth: 52
  implicitHeight: 18

  onDownloadHistoryChanged: graph.requestPaint()
  onUploadHistoryChanged: graph.requestPaint()
  onMaxRateChanged: graph.requestPaint()
  onWidthChanged: graph.requestPaint()
  onHeightChanged: graph.requestPaint()

  Canvas {
    id: graph
    anchors.fill: parent

    function drawSeries(ctx, samples, color, baselineFactor, amplitudeFactor) {
      if (!samples.length) return

      const maxRate = Math.max(1, root.maxRate)
      const step = samples.length > 1 ? width / (samples.length - 1) : width
      ctx.beginPath()

      for (let i = 0; i < samples.length; i++) {
        const sample = Math.max(0, Number(samples[i] || 0))
        const ratio = Math.min(1, sample / maxRate)
        const x = samples.length > 1 ? i * step : width / 2
        const baseline = height * baselineFactor
        const y = baseline - ratio * height * amplitudeFactor

        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }

      ctx.strokeStyle = color
      ctx.lineWidth = 1.15
      ctx.lineJoin = "round"
      ctx.lineCap = "round"
      ctx.stroke()
    }

    onPaint: {
      const ctx = getContext("2d")
      ctx.reset()

      ctx.beginPath()
      ctx.moveTo(0, height * 0.5)
      ctx.lineTo(width, height * 0.5)
      ctx.strokeStyle = root.idleColor
      ctx.lineWidth = 0.75
      ctx.stroke()

      drawSeries(ctx, root.downloadHistory, root.downloadColor, 0.82, 0.34)
      drawSeries(ctx, root.uploadHistory, root.uploadColor, 0.98, 0.2)
    }
  }
}
