{hyprland-nix, ...}: {
  imports = [hyprland-nix.homeManagerModules.default];

  wayland.windowManager.hyprland = {
    enable = true;
    reloadConfig = true;
    systemdIntegration = true;
    recommendedEnvironment = false;
    config = {};
  };
}
