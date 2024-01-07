{ config, pkgs, ... }:

{
  home = {
    # Alacritty
    file.".config/alacritty/alacritty.toml".source = ../dots/alacritty/alacritty.toml;

    # GitUI
    file.".config/gitui/key_bindings.ron".source = ../dots/gitui/key_bindings.ron;

    # Nushell
    file.".config/nushell/config.nu".source = ../dots/nushell/config.nu;
    file.".config/nushell/env.nu".source = ../dots/nushell/env.nu;
    file.".config/nushell/zoxide.nu".source = ../dots/nushell/zoxide.nu;

    # Qutebrowser
    file.".config/qutebrowser/config.py".source = ../dots/qutebrowser/config.py;

    # Zellij
    file.".config/zellij/config.kdl".source = ../dots/zellij/config.kdl;
  };
}
