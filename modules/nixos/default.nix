{
  # TODO: It would be nice to have a utility function that
  # just imports all the files in the current directory

  # NOTE: Nix doesn't support variables starting with a number,
  # so we have to prefix it with an underscore
  _1password = import ./1password.nix;
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
  security = import ./security.nix;
  users = import ./users.nix;
  xdg = import ./xdg.nix;
  xserver = import ./xserver.nix;
}
