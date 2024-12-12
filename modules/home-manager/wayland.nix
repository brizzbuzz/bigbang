{
  pkgs,
  osConfig,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports =
    if (isDesktop && isLinux)
    then [./hyprland]
    else [];

  home.packages =
    if (isDesktop && isLinux)
    then
      with pkgs; [
        libnotify
        swaynotificationcenter
        wl-clipboard
        wlogout
        wofi
        xwayland
        hyprpaper
        hyprpicker
        hyprshot
        hyprutils
      ]
    else [];
}
