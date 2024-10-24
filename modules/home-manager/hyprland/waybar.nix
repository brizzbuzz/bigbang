{pkgs-unstable, ...}: let
  temperature = pkgs-unstable.writeShellScriptBin "temperature" ''
    sensors | grep "Package id 0:" | awk '{print $4}' | cut -c 2-
  '';
in {
  enable = true;
  systemd = {
    enable = true;
    target = "hyprland-session.target";
  };
  settings = [{
    height = 40;
    layer = "top";
    position = "top";
    spacing = 4;
    margin-left = 15;
    margin-right = 15;
    margin-top = 8;

    modules-left = [
      "custom/launcher"
      "cpu"
      "memory"
      "temperature"
    ];
    modules-center = [
      "hyprland/workspaces"
    ];
    modules-right = [
      "pulseaudio"
      "network"
      "clock"
      "custom/power"
    ];

    "hyprland/workspaces" = {
      format = "{id}";
      on-click = "activate";
      active-only = false;
      all-outputs = true;
      show-special = false;
      persistent-workspaces = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4" = [];
        "5" = [];
      };
    };

    "custom/launcher" = {
      format = "";
      on-click = "wofi --show drun";
      tooltip = false;
    };

    "custom/power" = {
      format = "⏻";
      on-click = "wlogout";
      tooltip = false;
    };

    "cpu" = {
      interval = 10;
      format = " {}%";
      max-length = 10;
    };

    "temperature" = {
      format = " {temperatureC}°C";
    };

    "memory" = {
      interval = 30;
      format = " {}%";
      format-alt = " {used:0.1f}G";
      max-length = 10;
    };

    "pulseaudio" = {
      format = "{icon} {volume}%";
      format-muted = "婢";
      format-icons = {
        default = ["" "" ""];
      };
      on-click = "pavucontrol";
    };

    "network" = {
      format-wifi = "直 {signalStrength}%";
      format-ethernet = "";
      format-disconnected = "睊";
    };

    "clock" = {
      format = " {:%H:%M}";
      format-alt = " {:%Y-%m-%d}";
    };
  }];

  style = ''
    * {
      font-family: "SFPro", "JetBrainsMono Nerd Font";
      font-size: 14px;
      min-height: 0;
      border: none;
      border-radius: 0;
      box-shadow: none;
      text-shadow: none;
      padding: 0;
      margin: 0;
    }

    window#waybar {
      background: transparent;
    }

    .modules-left, .modules-center, .modules-right {
      background: rgba(17, 17, 27, 0.45);
      border-radius: 24px;
      padding: 4px;
      margin: 4px;
    }

    #workspaces {
      margin: 4px;
      padding: 0;
      background: transparent;
    }

    #workspaces button {
      color: #cdd6f4;
      background: rgba(49, 50, 68, 0.6);
      border-radius: 16px;
      padding: 2px 10px;
      margin: 0 2px;
      box-shadow: none;
      text-shadow: none;
      border: none;
      min-width: 30px;
    }

    #workspaces button:hover {
      background: rgba(49, 50, 68, 0.7);
      color: #cdd6f4;
    }

    #workspaces button.active {
      color: #11111b;
      background: rgba(147, 153, 178, 0.8);
    }

    #custom-launcher,
    #clock,
    #cpu,
    #temperature,
    #network,
    #pulseaudio,
    #custom-power,
    #memory {
      padding: 2px 12px;
      margin: 4px;
      border-radius: 16px;
      color: #11111b;
      box-shadow: none;
      text-shadow: none;
    }

    #custom-launcher {
      margin-left: 6px;
      background-color: rgba(203, 166, 247, 0.8);
    }

    #cpu {
      background-color: rgba(180, 190, 254, 0.8);
    }

    #temperature {
      background-color: rgba(137, 180, 250, 0.8);
    }

    #memory {
      background-color: rgba(116, 199, 236, 0.8);
    }

    #pulseaudio {
      background-color: rgba(148, 226, 213, 0.8);
    }

    #network {
      background-color: rgba(166, 227, 161, 0.8);
    }

    #clock {
      background-color: rgba(250, 179, 135, 0.8);
    }

    #custom-power {
      margin-right: 6px;
      background-color: rgba(243, 139, 168, 0.8);
      padding: 2px 16px;
    }
  '';
}
