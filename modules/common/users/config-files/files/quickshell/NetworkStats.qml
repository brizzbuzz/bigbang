import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property string interfaceName: ""
  property real downloadBps: 0
  property real uploadBps: 0
  property real peakDownloadBps: 0
  property real peakUploadBps: 0
  property real graphMaxBps: 1
  property var downloadHistory: []
  property var uploadHistory: []

  property int sampleCount: 24
  property int sampleInterval: 1000
  property real _previousRxBytes: -1
  property real _previousTxBytes: -1

  function reset() {
    root.downloadBps = 0
    root.uploadBps = 0
    root.peakDownloadBps = 0
    root.peakUploadBps = 0
    root.graphMaxBps = 1
    root.downloadHistory = []
    root.uploadHistory = []
    root._previousRxBytes = -1
    root._previousTxBytes = -1
  }

  function appendSample(history, value) {
    const next = history.slice()
    next.push(value)
    return next.slice(-root.sampleCount)
  }

  function updateSeries(rxBytes, txBytes) {
    if (root._previousRxBytes < 0 || root._previousTxBytes < 0) {
      root._previousRxBytes = rxBytes
      root._previousTxBytes = txBytes
      return
    }

    const rxDelta = Math.max(0, rxBytes - root._previousRxBytes)
    const txDelta = Math.max(0, txBytes - root._previousTxBytes)
    const intervalSeconds = root.sampleInterval / 1000
    const downloadBps = rxDelta / intervalSeconds
    const uploadBps = txDelta / intervalSeconds

    root._previousRxBytes = rxBytes
    root._previousTxBytes = txBytes
    root.downloadBps = downloadBps
    root.uploadBps = uploadBps
    root.downloadHistory = root.appendSample(root.downloadHistory, downloadBps)
    root.uploadHistory = root.appendSample(root.uploadHistory, uploadBps)

    const rxPeak = root.downloadHistory.length ? Math.max(...root.downloadHistory) : 0
    const txPeak = root.uploadHistory.length ? Math.max(...root.uploadHistory) : 0
    root.peakDownloadBps = rxPeak
    root.peakUploadBps = txPeak
    root.graphMaxBps = Math.max(1, rxPeak, txPeak)
  }

  function parseCounters(text) {
    if (!root.interfaceName) {
      root.reset()
      return
    }

    const lines = String(text || "").split("\n")
    for (const line of lines) {
      if (!line.includes(":")) continue

      const fields = line.trim().split(/[:\s]+/)
      if (fields[0] !== root.interfaceName) continue

      root.updateSeries(Number(fields[1] || 0), Number(fields[9] || 0))
      return
    }

    root.reset()
  }

  onInterfaceNameChanged: reset()

  Timer {
    interval: root.sampleInterval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: sampleProc.exec(["cat", "/proc/net/dev"])
  }

  Process {
    id: sampleProc
    stdout: StdioCollector {
      onStreamFinished: root.parseCounters(text)
    }
  }
}
