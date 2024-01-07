{ config, pkgs, ... }:

{
  home = {
    # Alacritty
    file.".config/alacritty/alacritty.toml".source = ../dots/alacritty/alacritty.toml;
    file.".config/alacritty/alacritty.yml".source = ../dots/alacritty/alacritty.yml;

    # Bat
    file.".config/bat/config".source = ../dots/bat/config;
    file.".config/bat/themes/Catppucin-macchiato.tmTheme".source = ../dots/bat/themes/Catppuccin-macchiato.tmTheme;

    # Git
    file.".gitconfig".source = ../dots/git/gitconfig;

    # GitUI
    file.".config/gitui/key_bindings.ron".source = ../dots/gitui/key_bindings.ron;

    # Hyprland
    file.".config/hypr/start.sh".source = ../dots/hypr/start.sh;

    # Nushell
    file.".config/nushell/config.nu".source = ../dots/nushell/config.nu;
    file.".config/nushell/env.nu".source = ../dots/nushell/env.nu;
    file.".config/nushell/zoxide.nu".source = ../dots/nushell/zoxide.nu;

    # Qutebrowser
    file.".config/qutebrowser/config.py".source = ../dots/qutebrowser/config.py;

    # SSH
    file.".ssh/config".source = ../dots/ssh/config;

    # Wofi
    file.".config/wofi/style.css".source = ../dots/wofi/style.css;

    # Zellij
    file.".config/zellij/config.kdl".source = ../dots/zellij/config.kdl;
  };
}
