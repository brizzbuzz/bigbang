{config, ...}: let
  admin = config.host.admin.name;
in {
  imports = [
    ../common # NOTE: This is required because home-manager gets evaluated as a separate attribute set... I think...
    ./alacritty.nix
    ./apps.nix
    ./art.nix
    ./bat.nix
    ./bottom.nix
    ./browsers.nix
    ./dev.nix
    ./direnv.nix
    ./dots.nix
    ./git.nix
    ./keyboard.nix
    ./neovim.nix
    ./networking.nix
    ./nushell.nix
    ./rclone.nix
    ./starship.nix
    ./terminal.nix
    ./wayland.nix
    ./zellij.nix
  ];

  home = {
    username = admin;
    homeDirectory = "/home/${admin}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
