{ config, pkgs, pkgs-unstable, ... }:

{
  services.aerospace = {
    enable = true;
    package = pkgs-unstable.aerospace;
    settings = {
      # Default container settings
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Window gaps
      gaps = {
        outer = {
          left = 8;
          right = 8;
          top = 8;
          bottom = 8;
        };
        inner = 8;
      };

      # Key bindings using alt as the modifier
      mode.main.binding = {
        # Focus windows
        "alt-h" = "focus left";
        "alt-j" = "focus down";
        "alt-k" = "focus up";
        "alt-l" = "focus right";

        # Move windows
        "alt-shift-h" = "move left";
        "alt-shift-j" = "move down";
        "alt-shift-k" = "move up";
        "alt-shift-l" = "move right";

        # Workspace management
        "alt-1" = "workspace 1";
        "alt-2" = "workspace 2";
        "alt-3" = "workspace 3";
        "alt-4" = "workspace 4";
        "alt-5" = "workspace 5";

        # Move windows to workspaces
        "alt-shift-1" = "move-node-to-workspace 1";
        "alt-shift-2" = "move-node-to-workspace 2";
        "alt-shift-3" = "move-node-to-workspace 3";
        "alt-shift-4" = "move-node-to-workspace 4";
        "alt-shift-5" = "move-node-to-workspace 5";

        # Layout controls
        "alt-f" = "toggle-float";
        "alt-r" = "toggle-layout";
        "alt-space" = "toggle-fullscreen";
      };

      # Window management preferences
      window-rules = [
        { matches = { app = "^System Settings$"; }; actions = ["float"]; }
        { matches = { app = "^Calculator$"; }; actions = ["float"]; }
      ];

      # Mouse behavior
      mouse = {
        modifier = "alt";
        enables-focus = true;
      };

      # Visual preferences
      accordion-padding = 30;

      # Move mouse to center of focused monitor when changing monitors
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
    };
  };
}
