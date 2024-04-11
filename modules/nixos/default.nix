{
  boot = import ./boot.nix;
  environment = import ./environment.nix;
  flake-support = import ./flake-support.nix;
  fonts = import ./fonts.nix;
  garbage-collection = import ./garbage-collection.nix;
  hardware = import ./hardware.nix;
  hyprland = import ./hyprland.nix;
  locale = import ./locale.nix;
  networking = import ./networking.nix;
  nvidia = import ./nvidia.nix;
  password-manager = import ./password-manager.nix;
  polkit = import ./polkit.nix;
  pueue = import ./pueue.nix;
  security = import ./security.nix;
  users = import ./users.nix;
  xdg = import ./xdg.nix;
  xserver = import ./xserver.nix;
}
