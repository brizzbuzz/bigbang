{ config, pkgs, ... }:

{
  imports = [
    ../home/apps.nix
    ../home/browsers.nix
    ../home/dots.nix
    ../home/keyboard.nix
    ../home/terminal.nix
    ../home/wayland.nix
  ];

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}
