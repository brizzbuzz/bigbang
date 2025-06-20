{
  config,
  opnix,
  pkgs,
  lib,
  ...
}: let
  currentUsername = config.home.username;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    opnix.homeManagerModules.default
    ../../common
    ../atuin.nix
    ../alacritty.nix
    ../apps.nix
    ../bat.nix
    ../bottom.nix
    ../direnv.nix
    ../dots.nix
    ../git.nix
    ../gitui.nix
    ../nushell.nix
    ../rclone.nix
    ../ssh.nix
    ../starship.nix
    ../terminal.nix
    ../wayland.nix
    ../zed.nix
    ../zellij.nix
    ../zoxide.nix
  ];

  home = {
    homeDirectory = lib.mkForce (
      if isDarwin
      then "/Users/${currentUsername}"
      else "/home/${currentUsername}"
    );
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  programs.git = {
    userName = "Ryan Brink";
    userEmail = "dev@ryanbr.ink";
  };

  programs.onepassword-secrets = lib.mkIf isLinux {
    enable = true;
    secrets = [
      {
        path = ".config/Yubico/u2f_keys";
        reference = "op://Homelab/U2F Keys/notesPlain";
      }
    ];
  };

  home.packages = with pkgs; [
    # Development tools
    nodejs
    python3
    rustc
    cargo
    go
    obsidian
    ffmpeg
    yt-dlp
  ];
}
