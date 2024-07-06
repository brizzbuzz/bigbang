{osConfig, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$base" = "0xff232136";
      "$surface" = "0xff2a273f";
      "$overlay" = "0xff393552";
      "$muted" = "0xff6e6a86";
      "$subtle" = "0xff908caa";
      "$text" = "0xffe0def4";
      "$love" = "0xffeb6f92";
      "$gold" = "0xfff6c177";
      "$rose" = "0xffea9a97";
      "$pine" = "0xff3e8fb0";
      "$foam" = "0xff9ccfd8";
      "$iris" = "0xffc4a7e7";
      "$highlightLow" = "0xff2a283e";
      "$highlightMed" = "0xff44415a";
      "$highlightHigh" = "0xff56526e";

      env = "XCURSOR_SIZE,24";

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
        gaps_in = 3;
        gaps_out = 5;
        border_size = 3;
        "col.active_border" = "$rose $pine $love $iris 90deg";
        "col.inactive_border" = "$muted";
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

      # master = {
      #   new_is_master = true;
      # };

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
          "$hypr, L, exec, hyprlock,"
          "$hypr, R, exec, wofi --show drun,"
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
        "waybar"
        "hyprpaper"
        "hypridle"
        "1password --silent"
        "systemctl start --user polkit-gnome-authentication-agent-1"
        # "[workspace special:discord silent] discord"
        # "[workspace special:browser silent] brave"
      ];
    };
  };
}
