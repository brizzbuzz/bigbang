{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.desktop.enable {
    environment.systemPackages = with pkgs; [
      # Status bar
      waybar

      # Launchers
      rofi

      # Emergency terminal
      foot

      # Notifications
      dunst
      libnotify

      # Hypr ecosystem
      hyprlock
      hypridle
      hyprpaper
      hyprpicker

      # Alternative wallpaper daemon (more modern)
      swww

      # Screenshots
      grim # Screenshot utility
      slurp # Region selector
      swappy # Screenshot editor

      # Screen recording
      wl-screenrec

      # Clipboard
      wl-clipboard
      cliphist

      # File manager
      thunar
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin

      # File manager dependencies
      gvfs # Trash, mounting, etc.
      tumbler # Thumbnails

      # Image viewer
      imv

      # PDF viewer
      zathura

      # Video player
      mpv

      # Audio control
      pavucontrol
      playerctl

      # Brightness control
      brightnessctl

      # Power management
      power-profiles-daemon

      # Multi-monitor GUI tool
      nwg-displays

      # System utilities
      wlr-randr
      wl-gammactl
      wtype

      # Polkit agent
      polkit_gnome

      # Wallpaper generator
      (python3.withPackages (ps: [ps.pillow]))
    ];

    # Enable power-profiles-daemon
    services.power-profiles-daemon.enable = true;

    # Enable thunar and its services
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    services.gvfs.enable = true;
    services.tumbler.enable = true;

    # Brightness control permissions
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';

    # Add video group for brightness control
    users.groups.video = {};

    # XDG user directories
    environment.sessionVariables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };

    systemd.user.services.hypr-wallpaper-generator = {
      description = "Generate dot wallpaper for Hyprland";
      serviceConfig = {
        Type = "oneshot";
        Environment = "PATH=/run/current-system/sw/bin";
        ExecStart = "${pkgs.python3.withPackages (ps: [ps.pillow])}/bin/python %h/.config/hypr/scripts/generate-dots-wallpaper.py";
      };
    };

    systemd.user.timers.hypr-wallpaper-generator = {
      description = "Refresh dot wallpaper every minute";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "60s";
      };
    };
  };
}
