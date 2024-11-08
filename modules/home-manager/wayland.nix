{
  pkgs,
  osConfig,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = osConfig.host.isDarwin;
in {
  imports =
    if (isDesktop && !isDarwin)
    then [./hyprland]
    else [];

  home.packages =
    if (isDesktop && !isDarwin)
    then
      with pkgs; [
        libnotify
        swaynotificationcenter
        waybar
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
