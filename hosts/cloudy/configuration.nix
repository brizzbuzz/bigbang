{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
    inputs.home-manager.nixosModules.home-manager
  ];
  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
    jellyfin.server.enable = true;
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;

  system.stateVersion = "24.05";
}
