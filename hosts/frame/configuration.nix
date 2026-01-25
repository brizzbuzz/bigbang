{...}: {
  imports = [
    ./hardware-configuration.nix
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
