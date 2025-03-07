{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
  ];

  host = {
    name = "frame";
  };

  system.stateVersion = "24.05";
}
