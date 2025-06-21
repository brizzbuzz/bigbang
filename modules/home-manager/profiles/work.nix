{
  config,
  opnix,
  pkgs,
  lib,
  ...
}: let
  currentUsername = config.home.username;
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
    userEmail = "ryan@withodyssey.com";
  };

  home.packages = with pkgs; [
    nodejs
    python3
    wget
    curl
    jq
  ];

  programs.ssh.enable = lib.mkDefault false;
}
