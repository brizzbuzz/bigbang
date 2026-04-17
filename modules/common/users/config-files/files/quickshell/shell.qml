import Quickshell

Scope {
  Variants {
    model: Quickshell.screens

    ScreenShell {
      required property var modelData
      screen: modelData
    }
  }
}
