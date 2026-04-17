import Quickshell
import "."

Scope {
  id: root

  required property var screen

  Bar {
    screen: root.screen
  }

  Sidebar {
    screen: root.screen
  }
}
