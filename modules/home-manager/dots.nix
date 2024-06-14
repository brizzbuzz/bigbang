{
  osConfig,
  lib,
  ...
}: {
  home = {
    # Alacritty
    file.".config/alacritty/alacritty.toml".source = ./dots/alacritty/alacritty.toml;
    file.".config/alacritty/rose-pine-moon.toml".source = ./dots/alacritty/rose-pine-moon.toml;

    # Bat
    file.".config/bat/config".source = ./dots/bat/config;
    file.".config/bat/themes/Catppucin-macchiato.tmTheme".source = ./dots/bat/themes/Catppuccin-macchiato.tmTheme;

    # Bottom
    file.".config/bottom/bottom.toml".source = ./dots/bottom/bottom.toml;

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

    # Process Compose
    file.".config/process-compose" = {
      source = ./dots/process-compose;
      recursive = true;
    };

    # Qutebrowser
    file.".config/qutebrowser/config.py".source = ./dots/qutebrowser/config.py;

    # SSH
    #file.".ssh/config" = lib.mkIf osConfig.host.desktop.enable {
    #  source = ./dots/ssh/config;
    #};

    # Starship
    file.".config/starship.toml".source = ./dots/starship/starship.toml;

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

    # Zellij
    file.".config/zellij".source = ./dots/zellij;
    file.".config/zellij".recursive = true;
  };
}
