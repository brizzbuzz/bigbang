{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    hyprpaper # TODO: Would like to replace SWWW but this wasn't working for me :(
    libnotify
    mako
    swaylock-effects
    swww
    waybar
    wofi
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    #enableNvidiaPatches = true;
    xwayland.enable = true;
    extraConfig = builtins.readFile ../dots/hypr/hyprland.conf;
  };
}
