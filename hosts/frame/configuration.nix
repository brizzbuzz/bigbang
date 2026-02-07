{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/common
    ../../modules/nixos
  ];

  host = {
    name = "frame";
    desktop.enable = true;
    userManagement.enable = true;
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
      };
    };
  };

  system.stateVersion = "24.05";
}
