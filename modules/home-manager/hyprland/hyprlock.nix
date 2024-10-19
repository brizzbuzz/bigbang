{pkgs-unstable, ...}: let
  colors = import ./theme.nix;
in {
  enable = true;
  package = with pkgs-unstable;
    hyprlock.overrideAttrs (old: {
      version = "git";
      # See https://github.com/hyprwm/hyprlock/issues/128
      src = fetchFromGitHub {
        owner = "hyprwm";
        repo = "hyprlock";
        rev = "1169452";
        sha256 = "3dDOBfFkmusoF+6LWXkvQaSfzXb0DEqMEQQvEBbjN9Q=";
      };
      patchPhase = ''
        substituteInPlace src/core/hyprlock.cpp \
        --replace "5000" "16"
      '';
    });

  settings = {
    general = {
      disable_loading_bar = true;
      hide_cursor = true;
    };

    background = {
      monitor = "";
      path = "/home/ryan/Pictures/moonlight-mountain.png";
      color = colors.base;
    };

    input-field = [
      {
        monitor = "";
        size = {
          width = 300;
          height = 60;
        };
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = colors.mauve;
        inner_color = colors.surface0;
        font_color = colors.text;
        fade_on_empty = false;
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        check_color = colors.mauve;
        fail_color = colors.red;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = colors.yellow;
        position = {
          x = 0;
          y = -47;
        };
        halign = "center";
        valign = "center";
      }
    ];

    image = [
      {
        monitor = "";
        path = "/home/ryan/Pictures/catppuccin.png";
        size = 100;
        border_color = colors.mauve;
        position = {
          x = 0;
          y = 75;
        };
        halign = "center";
        valign = "center";
      }
    ];
  };
}
