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
    inputs.home-manager.nixosModules.home-manager
  ];

  host.name = "cloudy";
  host.admin.name = "god";
  host.desktop.enable = false;
  host.remote.enable = true;

  system.stateVersion = "23.11";
}
