{
  osConfig,
  pkgs,
  ...
}: {
  programs.hyprlock = import ./hyprlock.nix {inherit pkgs;};
  programs.waybar = import ./waybar.nix {inherit pkgs;};

  wayland.windowManager.hyprland = import ./config.nix {inherit osConfig;};
}
