{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      libnotify
      mako
      waybar
      wlogout
      wofi
      xwayland
    ])
    ++ (with pkgs-unstable; [
      hyprlock
      hyprpaper
      hyprpicker
    ]);

  wayland.windowManager.hyprland = {
    enable = true;
    #enableNvidiaPatches = true;
    xwayland.enable = true;
    extraConfig = builtins.readFile ../dots/hypr/hyprland.conf;
  };
}
