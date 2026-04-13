{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.roles.desktop {
    environment.systemPackages = with pkgs; [
      waybar
      walker
      elephant
      foot
      swaynotificationcenter
      libnotify
      hyprlock
      hypridle
      hyprpaper
      hyprpicker
      swww
      grim
      slurp
      swappy
      wl-screenrec
      wl-clipboard
      cliphist
      thunar
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
      gvfs
      tumbler
      imv
      zathura
      mpv
      pavucontrol
      playerctl
      brightnessctl
      power-profiles-daemon
      nwg-displays
      wlr-randr
      wl-gammactl
      wtype
      (python3.withPackages (ps: [ps.pillow]))
    ];

    services.power-profiles-daemon.enable = true;

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

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';

    users.groups.video = {};

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
