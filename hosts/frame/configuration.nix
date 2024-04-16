{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
  ];

  host = {
    name = "frame";
  };

  system.stateVersion = "23.11";
}
