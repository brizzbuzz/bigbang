{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    libnotify
    mako
    swaylock-effects
    swww
    waybar
    wofi
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
    extraConfig = builtins.readFile ../dots/hypr/hyprland.conf;
  };
}
