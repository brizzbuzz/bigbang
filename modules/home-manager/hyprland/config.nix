{osConfig}: let
  colors = import ./theme.nix;
in {
  enable = true;
  xwayland.enable = true;

  settings = {
    "$rosewater" = colors.rosewater;
    "$flamingo" = colors.flamingo;
    "$pink" = colors.pink;
    "$mauve" = colors.mauve;
    "$red" = colors.red;
    "$maroon" = colors.maroon;
    "$peach" = colors.peach;
    "$yellow" = colors.yellow;
    "$green" = colors.green;
    "$teal" = colors.teal;
    "$sky" = colors.sky;
    "$sapphire" = colors.sapphire;
    "$blue" = colors.blue;
    "$lavender" = colors.lavender;
    "$text" = colors.text;
    "$subtext1" = colors.subtext1;
    "$subtext0" = colors.subtext0;
    "$overlay2" = colors.overlay2;
    "$overlay1" = colors.overlay1;
    "$overlay0" = colors.overlay0;
    "$surface2" = colors.surface2;
    "$surface1" = colors.surface1;
    "$surface0" = colors.surface0;
    "$base" = colors.base;
    "$mantle" = colors.mantle;
    "$crust" = colors.crust;

    env = "XCURSOR_SIZE,24";

    cursor = {
      no_hardware_cursors = true;
    };

    # TODO: Need to move to host-info
    monitor = [
      "eDP-1,2256x1504@60,0x0,1"
    ];

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = "no";
      };
      sensitivity = 0;
    };

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 3;
      "col.active_border" = "$pink $teal $red $mauve 90deg";
      "col.inactive_border" = "$surface0";
      layout = "dwindle";
      allow_tearing = false;
    };

    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
      };
      drop_shadow = "yes";
      shadow_range = 4;
      shadow_render_power = 3;
      "col.shadow" = "rgba(1a1a1aee)";
    };

    animations = {
      enabled = "yes";
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      pseudotile = "yes";
      preserve_split = "yes";
    };

    gestures = {
      workspace_swipe = "off"; # TODO: Switch to on for laptop?
    };

    misc = {
      force_default_wallpaper = 0;
    };

    "$hypr" =
      if osConfig.host.keyboard == "moonlander"
      then "ALT SHIFT CTRL SUPER"
      else "ALT CTRL";

    "$meh" =
      if osConfig.host.keyboard == "moonlander"
      then "ALT SHIFT CTRL"
      else "ALT CTRL SHIFT";

    bind =
      [
        "$hypr, C, killactive,"
        "$meh, B, exec, floorp"
        "$hypr, R, exec, wofi --show drun,"
        "$hypr, L, exec, hyprlock"
      ]
      ++ [
        "$meh, H, movefocus, l"
        "$meh, J, movefocus, d"
        "$meh, K, movefocus, u"
        "$meh, L, movefocus, r"
      ]
      ++ [
        "$meh, S, togglespecialworkspace, magic"
        "$hypr, S, movetoworkspace, special:magic"
      ]
      ++ [
        # "$meh, D, togglespecialworkspace, discord"
        # "$meh, B, togglespecialworkspace, browser"
      ]
      ++ [
        "$meh, P, exec, 1password --quick-access --enable-features=UseOzonePlatform --ozone-platform=wayland"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$meh, ${ws}, workspace, ${toString (x + 1)}"
              "$hypr, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );

    bindm = [
      "$hypr, mouse:272, movewindow"
      "$hypr, mouse:273, resizewindow"
    ];

    "exec-once" = [
      "hyprpaper"
      "hypridle"
      "swaync"
      "waybar"
      "1password --silent"
      "systemctl start --user polkit-gnome-authentication-agent-1"
      # "[workspace special:discord silent] discord"
      # "[workspace special:browser silent] brave"
    ];
  };
}
