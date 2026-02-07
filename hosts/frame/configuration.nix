{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.opnix.nixosModules.default
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

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan" "Work"];
    secrets = {
      kagiApiKey = {
        reference = "op://Homelab/Kagi Api Key/notesPlain";
        path = "/var/lib/opnix/secrets/kagi-api-key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    google-chrome
  ];

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
