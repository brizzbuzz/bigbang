{
  pkgs,
  pkgs-unstable,
  osConfig,
  lib,
  ...
}: let
  isDeskop = osConfig.host.desktop.enable;
  isDarwin = osConfig.host.isDarwin;
in
  lib.mkIf (isDeskop && isDarwin)
  {
    imports = [./hyprland];

    home.packages =
      (with pkgs; [
        libnotify
        mako
        waybar
        wl-clipboard
        wlogout
        wofi
        xwayland
      ])
      ++ (with pkgs-unstable; [
        hyprlock
        hyprpaper
        hyprpicker
      ]);
  }
