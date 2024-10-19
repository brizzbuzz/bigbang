{
  osConfig,
  pkgs-unstable,
  ...
}: {
  programs.hyprlock = import ./hyprlock.nix {inherit pkgs-unstable;};

  wayland.windowManager.hyprland = import ./config.nix {inherit osConfig;};
}
