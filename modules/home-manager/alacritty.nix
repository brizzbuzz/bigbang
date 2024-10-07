{
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dynamic_padding = true;
        padding = {
          x = 10;
          y = 10;
        };
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 12;
      };
      colors = {
        primary = {
          foreground = "#e0def4";
          background = "#232136";
          dim_foreground = "#908caa";
          bright_foreground = "#e0def4";
        };
        cursor = {
          text = "#e0def4";
          cursor = "#56526e";
        };
        vi_mode_cursor = {
          text = "#e0def4";
          cursor = "#56526e";
        };
        search = {
          matches = {
            foreground = "#908caa";
            background = "#393552";
          };
          focused_match = {
            foreground = "#232136";
            background = "#ea9a97";
          };
        };
        hints = {
          start = {
            foreground = "#908caa";
            background = "#2a273f";
          };
          end = {
            foreground = "#6e6a86";
            background = "#2a273f";
          };
        };
        line_indicator = {
          foreground = "None";
          background = "None";
        };
        footer_bar = {
          foreground = "#e0def4";
          background = "#2a273f";
        };
        selection = {
          text = "#e0def4";
          background = "#44415a";
        };
        normal = {
          black = "#393552";
          red = "#eb6f92";
          green = "#3e8fb0";
          yellow = "#f6c177";
          blue = "#9ccfd8";
          magenta = "#c4a7e7";
          cyan = "#ea9a97";
          white = "#e0def4";
        };
        bright = {
          black = "#6e6a86";
          red = "#eb6f92";
          green = "#3e8fb0";
          yellow = "#f6c177";
          blue = "#9ccfd8";
          magenta = "#c4a7e7";
          cyan = "#ea9a97";
          white = "#e0def4";
        };
        dim = {
          black = "#6e6a86";
          red = "#eb6f92";
          green = "#3e8fb0";
          yellow = "#f6c177";
          blue = "#9ccfd8";
          magenta = "#c4a7e7";
          cyan = "#ea9a97";
          white = "#e0def4";
        };
      };
    };
  };
}
