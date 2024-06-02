{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
  ];

  host = {
    keyboard = "framework";
    name = "frame";
  };

  system.stateVersion = "24.05";
}
