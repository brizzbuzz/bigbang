{
  pkgs,
  pkgs-unstable,
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
      ])
    else [];
}
