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

  services.fwupd.enable = true;

  # Declarative WiFi configuration
  # NetworkManager will remember these networks and connect automatically
  networking.networkmanager = {
    enable = true;
    ensureProfiles.profiles = {
      home-wifi = {
        connection = {
          id = "BrizzNet";
          type = "wifi";
          autoconnect = "true";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "------";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "------";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };
  };

  system.stateVersion = "24.05";
}
