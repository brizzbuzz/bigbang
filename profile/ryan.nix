{ config, pkgs, ... }:

{
  imports = [
    ../home/apps.nix
    ../home/browsers.nix
    ../home/dots.nix
    ../home/keyboard.nix
    ../home/terminal.nix
  ];

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
    extraConfig = ( builtins.readFile ../dots/hypr/hyprland.conf);
  };
}
