{inputs, ...}: {
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
  };

  system.stateVersion = "23.11";
}
