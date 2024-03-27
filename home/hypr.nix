{hyprland-nix, ...}: {
  imports = [hyprland-nix.homeManagerModules.default];

  wayland.windowManager.hyprland = {
    #enable = true;
    config = {};
  };
}
