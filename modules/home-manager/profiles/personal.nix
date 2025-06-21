{
  config,
  opnix,
  pkgs,
  lib,
  hostUsers,
  ...
}: let
  # Get current user from home.username
  currentUsername = config.home.username;
  userConfig = hostUsers.${currentUsername} or null;
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

  # Personal profile specific configurations
  programs.git = {
    userName = "Ryan Brink";
    userEmail = "dev@ryanbr.ink";
  };

  # Enable OnePassword secrets for Linux personal users
  programs.onepassword-secrets = lib.mkIf isLinux {
    enable = true;
    secrets = [
      {
        path = ".config/Yubico/u2f_keys";
        reference = "op://Homelab/U2F Keys/notesPlain";
      }
    ];
  };

  # Personal user gets full development environment
  home.packages = with pkgs; [
    # Development tools
    nodejs
    python3
    rustc
    cargo
    go

    # Personal productivity
    obsidian

    # Media tools
    ffmpeg
    yt-dlp
  ];

  # Personal profile specific dotfiles and configurations
  # xdg.configFile configurations can be added here as needed
}
