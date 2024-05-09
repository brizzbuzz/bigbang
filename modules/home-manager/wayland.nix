{
  pkgs,
  pkgs-unstable,
  ...
}: {
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
