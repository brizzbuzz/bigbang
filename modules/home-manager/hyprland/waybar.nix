{pkgs-unstable, ...}: let
  temperature = pkgs-unstable.writeShellScriptBin "temperature" ''
    sensors | grep "Package id 0:" | awk '{print $4}' | cut -c 2-
  '';
in {
 enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 5;
      margin-left = 10;
      margin-right = 10;
      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [
        "clock"
        "custom/weather"
      ];
      modules-right = [
        "cpu"
        "custom/gpu"
        "memory"
        "custom/temp"
        "pulseaudio"
        "tray"
        "custom/power"
      ];

      "custom/launcher" = {
        format = " ";
        on-click = "wofi --show drun";
        tooltip = false;
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "urgent" = "";
          "active" = "";
          "default" = "";
        };
        sort-by-number = true;
      };

      "hyprland/submap" = {
        format = "{}";
        max-length = 8;
        tooltip = false;
      };

      "clock" = {
        format = "{:%H:%M}";
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      "custom/weather" = {
        exec = "curl 'https://wttr.in/?format=1'";
        interval = 3600;
      };

      "cpu" = {
        format = "{usage}% ";
        tooltip = false;
      };

      "custom/gpu" = {
        exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}'";
        format = "{}% 󰢮";
        return-type = "json";
        interval = 10;
      };

      "memory" = {
        format = "{}% ";
      };

      "custom/temp" = {
        exec = "${temperature}/bin/temperature";
        format = "{}°C 󰔏";
        interval = 10;
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "婢 Muted";
        format-icons = {
          default = ["" "" ""];
        };
        on-click = "pavucontrol";
      };

      "tray" = {
        icon-size = 21;
        spacing = 10;
      };

      "custom/power" = {
        format = "⏻";
        on-click = "wlogout &";
        tooltip = false;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.5);
        color: #cdd6f4;
        border-radius: 15px;
      }

      #workspaces {
        background: #1e1e2e;
        margin: 5px;
        padding: 0 5px;
        border-radius: 10px;
      }

      #workspaces button {
        padding: 0 5px;
        color: #cdd6f4;
        border-radius: 8px;
        margin: 3px 0;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background: #cba6f7;
      }

      #clock,
      #cpu,
      #custom-gpu,
      #memory,
      #custom-temp,
      #pulseaudio,
      #custom-weather,
      #tray,
      #custom-power,
      #custom-launcher {
        background: #1e1e2e;
        padding: 0 10px;
        margin: 5px 0;
        border-radius: 10px;
      }

      #custom-launcher {
        color: #f5c2e7;
        font-size: 20px;
        margin-left: 15px;
        margin-right: 10px;
      }

      #clock {
        color: #fab387;
      }

      #cpu {
        color: #f38ba8;
      }

      #custom-gpu {
        color: #f9e2af;
      }

      #memory {
        color: #a6e3a1;
      }

      #custom-temp {
        color: #89b4fa;
      }

      #pulseaudio {
        color: #89dceb;
      }

      #custom-weather {
        color: #94e2d5;
      }

      #tray {
        color: #b4befe;
      }

      #custom-power {
        color: #f38ba8;
        margin-right: 15px;
      }
    '';
  }
