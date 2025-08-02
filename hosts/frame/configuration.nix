{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
  ];

  host = {
    name = "frame";
    desktop.enable = true;
  };

  system.stateVersion = "24.05";
}
