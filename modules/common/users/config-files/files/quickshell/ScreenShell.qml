import Quickshell
import "."

Scope {
  id: root

  required property var screen

  property bool powerOverlayOpen: false

  function run(command) {
    Quickshell.execDetached(["sh", "-c", command])
  }

  function openPowerOverlay() {
    root.powerOverlayOpen = true
  }

  function closePowerOverlay() {
    root.powerOverlayOpen = false
  }

  Bar {
    screen: root.screen
  }

  Sidebar {
    screen: root.screen
    openPowerMenu: root.openPowerOverlay
  }

  PowerOverlay {
    screen: root.screen
    open: root.powerOverlayOpen
    runCommand: root.run
    dismissOverlay: root.closePowerOverlay
  }
}
