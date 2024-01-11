{
  config,
  pkgs,
  lib,
  ...
}: {

  options = {
    desktopEnabled = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Set true if a desktop environment is present
      '';
    };
  };

  config = {
    home = {
      # Alacritty
      file.".config/alacritty/alacritty.toml".source = ../dots/alacritty/alacritty.toml;
      file.".config/alacritty/alacritty.yml".source = ../dots/alacritty/alacritty.yml;

      # Bat
      file.".config/bat/config".source = ../dots/bat/config;
      file.".config/bat/themes/Catppucin-macchiato.tmTheme".source = ../dots/bat/themes/Catppuccin-macchiato.tmTheme;

      # Git
      file.".gitconfig".source = if config.desktopEnabled then ../dots/git/gitconfig-desktop else ../dots/git/gitconfig-shell;

      # GitUI
      file.".config/gitui/key_bindings.ron".source = ../dots/gitui/key_bindings.ron;

      # Hyprland
      file.".config/hypr/start.sh".source = ../dots/hypr/start.sh;
      file.".config/hypr/macchiato-theme.conf".source = ../dots/hypr/macchiato-theme.conf;

      # Nushell
      file.".config/nushell/config.nu".source = ../dots/nushell/config.nu;
      file.".config/nushell/env.nu".source = ../dots/nushell/env.nu;
      file.".config/nushell/starship.nu".source = ../dots/nushell/starship.nu;
      file.".config/nushell/zoxide.nu".source = ../dots/nushell/zoxide.nu;

      # Nvim
      file.".config/nvim/init.lua".source = ../dots/nvim/init.lua;
      file.".config/nvim/lua/custom/plugins/init.lua".source = ../dots/nvim/lua/custom/plugins/init.lua;
      file.".config/nvim/lua/kickstart/plugins/autoformat.lua".source = ../dots/nvim/lua/kickstart/plugins/autoformat.lua;
      file.".config/nvim/lua/kickstart/plugins/debug.lua".source = ../dots/nvim/lua/kickstart/plugins/debug.lua;

      # Qutebrowser
      file.".config/qutebrowser/config.py".source = ../dots/qutebrowser/config.py;

      # SSH
      file.".ssh/config".source = if config.desktopEnabled then ../dots/ssh/config-desktop else ../dots/ssh/config-shell;

      # Starship
      file.".config/starship.toml".source = ../dots/starship/starship.toml;

      # Waybar
      file.".config/waybar/config".source = ../dots/waybar/config.json;
      file.".config/waybar/hotswap.sh".source = ../dots/waybar/hotswap.sh; # TODO: Nuify
      file.".config/waybar/style.css".source = ../dots/waybar/style.css;

      # Wofi
      file.".config/wofi/style.css".source = ../dots/wofi/style.css;

      # Zellij
      file.".config/zellij/config.kdl".source = ../dots/zellij/config.kdl;
    };
  };
}
