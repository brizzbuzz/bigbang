{config, ...}: let
  admin = config.host.admin.name;
in {
  imports = [
    ../common # NOTE: This is required because home-manager gets evaluated as a separate attribute set... I think...
    ./apps.nix
    ./art.nix
    ./browsers.nix
    ./dev.nix
    ./dots.nix
    ./gaming.nix
    ./git.nix
    ./keyboard.nix
    ./neovim.nix
    ./networking.nix
    ./rclone.nix
    ./terminal.nix
    ./wayland.nix
  ];

  home = {
    username = admin;
    homeDirectory = "/home/${admin}";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}
