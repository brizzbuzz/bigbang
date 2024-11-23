{
  osConfig,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    hyprpanel
  ];

  programs.hyprlock = import ./hyprlock.nix {inherit pkgs;};

  wayland.windowManager.hyprland = import ./config.nix {inherit osConfig;};
}
