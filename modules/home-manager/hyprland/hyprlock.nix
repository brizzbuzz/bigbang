{pkgs-unstable, ...}: {
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
      grace = 0;
      no_fade_in = false;
    };

    background = {
      monitor = "";
      path = "/home/ryan/Pictures/moonlight-mountain.png";
      color = "rgb(24, 25, 38)";

      blur_passes = 2;
      blur_size = 7;
      noise = 0.0117;
      contrast = 0.8916;
      brightness = 0.8172;
      vibrancy = 0.1696;
      vibrancy_darkness = 0.0;
    };

    input-field = {
      monitor = "";
      size = {
        width = 250;
        height = 50;
      };
      outline_thickness = 2;
      dots_size = 0.2;
      dots_spacing = 0.15;
      dots_center = true;
      outer_color = "rgb(110, 108, 126)";
      inner_color = "rgb(49, 50, 68)";
      font_color = "rgb(202, 211, 245)";
      fade_on_empty = true;
      placeholder_text = "<i>Password</i>";
      hide_input = true;
      position = {
        x = 0;
        y = 0;
      };
      halign = "center";
      valign = "center";
    };

    label = [
      {
        monitor = "";
        text = "$TIME";
        color = "rgb(202, 211, 245)";
        font_size = 64;
        font_family = "Sans";
        position = {
          x = 0;
          y = -80;
        };
        halign = "center";
        valign = "center";
      }
      {
        monitor = "";
        text = "Type to unlock";
        color = "rgb(165, 173, 203)";
        font_size = 18;
        font_family = "Sans";
        position = {
          x = 0;
          y = 60;
        };
        halign = "center";
        valign = "center";
      }
    ];
  };
}
