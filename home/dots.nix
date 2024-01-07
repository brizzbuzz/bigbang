{ config, pkgs, ... }:

{
  home = {
    # Alacritty
    file.".config/alacritty/alacritty.toml".source = ../dots/alacritty/alacritty.toml;
    file.".config/alacritty/alacritty.yml".source = ../dots/alacritty/alacritty.yml;

    # Git
    file.".gitconfig".source = ../dots/git/gitconfig;

    # GitUI
    file.".config/gitui/key_bindings.ron".source = ../dots/gitui/key_bindings.ron;

    # Nushell
    file.".config/nushell/config.nu".source = ../dots/nushell/config.nu;
    file.".config/nushell/env.nu".source = ../dots/nushell/env.nu;
    file.".config/nushell/zoxide.nu".source = ../dots/nushell/zoxide.nu;

    # Qutebrowser
    file.".config/qutebrowser/config.py".source = ../dots/qutebrowser/config.py;

    # SSH
    file.".ssh/config".source = ../dots/ssh/config;

    # Zellij
    file.".config/zellij/config.kdl".source = ../dots/zellij/config.kdl;
  };
}
