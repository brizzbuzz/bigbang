{
  osConfig,
  lib,
  ...
}: {
  home = {
    # GitUI
    file.".config/gitui".source = ./dots/gitui;
    file.".config/gitui".recursive = true;

    # Hyprland
    file.".config/hypr".source = ./dots/hypr;
    file.".config/hypr".recursive = true;

    # Kanata
    file.".config/kanata" = {
      source = ./dots/kanata;
      recursive = true;
    };

    # Mako
    file.".config/mako/config".source = ./dots/mako/config;

    # Nushell
    file.".config/nushell" = {
      source = ./dots/nushell;
      recursive = true;
    };

    # Nvim
    file.".config/nvim".source = ./dots/nvim;
    file.".config/nvim".recursive = true;

    # Posting
    file.".config/posting" = {
      source = ./dots/posting;
      recursive = true;
    };

    # Process Compose
    file.".config/process-compose" = {
      source = ./dots/process-compose;
      recursive = true;
    };

    # Qutebrowser
    file.".config/qutebrowser/config.py".source = ./dots/qutebrowser/config.py;

    # SSH
    file.".ssh/config" = lib.mkIf osConfig.host.desktop.enable {
      source =
        if !osConfig.host.isDarwin
        then ./dots/ssh/home-config
        else ./dots/ssh/work-config;
    };

    # WLogout
    file.".config/wlogout".source = ./dots/wlogout;
    file.".config/wlogout".recursive = true;

    # Waybar
    file.".config/waybar".source = ./dots/waybar;
    file.".config/waybar".recursive = true;

    # Wofi
    file.".config/wofi/style.css".source = ./dots/wofi/style.css;

    # XModMap
    file.".config/xmodmap/xmodmap".source = ./dots/xmodmap/xmodmap;

    # Yubico
    file.".config/Yubico/u2f_keys".source = ./dots/yubico/u2f_keys;
  };
}
