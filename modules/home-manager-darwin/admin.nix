{
  config,
  lib,
  nixvim,
  ...
}: let
  admin = config.host.admin.name;
in {
  # TODO: find a way to merge this with the default home-manager config
  imports = [
    nixvim.homeManagerModules.nixvim
    ../common
    ../home-manager/atuin.nix
    ../home-manager/alacritty.nix
    ../home-manager/apps.nix
    ../home-manager/bat.nix
    ../home-manager/bottom.nix
    ../home-manager/direnv.nix
    ../home-manager/dots.nix
    ../home-manager/git.nix
    ../home-manager/gitui.nix
    ../home-manager/neovim
    ../home-manager/networking.nix
    ../home-manager/nushell.nix
    ../home-manager/rclone.nix
    ../home-manager/ssh.nix
    ../home-manager/starship.nix
    ../home-manager/terminal.nix
    ../home-manager/wayland.nix
    ../home-manager/zellij.nix
    ../home-manager/zoxide.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    username = admin;
    homeDirectory = lib.mkForce "/Users/${admin}";
    stateVersion = "24.05";
  };
}
