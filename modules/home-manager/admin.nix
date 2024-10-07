{config, ...}: let
  admin = config.host.admin.name;
in {
  imports = [
    ../common # NOTE: This is required because home-manager gets evaluated as a separate attribute set... I think...
    ./atuin.nix
    ./alacritty.nix
    ./apps.nix
    ./bat.nix
    ./bottom.nix
    ./direnv.nix
    ./dots.nix
    ./git.nix
    ./gitui.nix
    ./neovim.nix
    ./networking.nix
    ./nushell.nix
    ./rclone.nix
    ./starship.nix
    ./terminal.nix
    ./wayland.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home = {
    username = admin;
    homeDirectory = "/home/${admin}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
