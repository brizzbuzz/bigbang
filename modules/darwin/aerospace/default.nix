{pkgs, ...}: {
  services.aerospace = {
    enable = false; # TODO: Enable once it doesn't suck
    package = pkgs.aerospace;
    settings = {
      # Basic window management settings
      default-root-container-layout = "tiles";
      default-root-container-orientation = "horizontal";

      # Enable standard container normalizations
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Window gaps
      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          left = 10;
          right = 10;
          top = 25;
          bottom = 10;
        };
      };

      # Basic keybindings for window management (using alt/option key)
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
      };

      # Mouse behavior
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

      # Set accordion padding
      accordion-padding = 30;
    };
  };
}
