{
  config,
  opnix,
  pkgs,
  lib,
  ...
}: let
  admin = config.host.admin.name;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    opnix.homeManagerModules.default
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
    ./nushell.nix
    ./rclone.nix
    ./ssh.nix
    ./starship.nix
    ./terminal.nix
    ./wayland.nix
    ./zed.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home = {
    username = admin;
    homeDirectory = lib.mkForce (
      if isDarwin
      then "/Users/${admin}"
      else "/home/${admin}"
    );
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  programs.onepassword-secrets = lib.mkIf isLinux {
    enable = true;
    secrets = {
      yubicoU2fKeys = {
        reference = "op://Homelab/U2F Keys/notesPlain";
        path = ".config/Yubico/u2f_keys";
        mode = "0600";
      };
    };
  };
}
