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
in {
  imports = [
    opnix.homeManagerModules.default
    ../../common
    ../atuin.nix
    ../alacritty.nix
    ../bat.nix
    ../bottom.nix
    ../direnv.nix
    ../dots.nix
    ../git.nix
    ../gitui.nix
    ../nushell.nix
    ../ssh.nix
    ../starship.nix
    ../terminal.nix
    ../zoxide.nix
    # Note: Excluding some personal modules like rclone, wayland, zed, zellij for work profile
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

  # Work profile specific configurations
  programs.git = {
    userName = "Ryan Brink";
    userEmail = "ryan@work.com"; # Use work email
  };

  # Work user gets limited development environment
  home.packages = with pkgs; [
    # Essential development tools only
    nodejs
    python3

    # Business productivity
    slack

    # System utilities
    wget
    curl
    jq
  ];

  # Work profile specific shell aliases
  programs.zsh.shellAliases = lib.mkIf (pkgs.stdenv.isDarwin) {
    work-vpn = "echo 'Connect to work VPN'";
    work-docs = "open ~/Documents/Work";
  };

  # Restrict certain configurations for work profile
  programs.ssh.enable = lib.mkDefault false; # Company may manage SSH keys

  # Work-specific dotfiles (minimal configuration)
  xdg.configFile = lib.mkIf isDarwin {
    "work-profile/.keep".text = "Work profile configuration";
  };

  # Work profile specific environment variables
  home.sessionVariables = {
    WORK_PROFILE = "true";
    NODE_ENV = "production";
  };
}
