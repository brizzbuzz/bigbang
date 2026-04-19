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
    roles.desktop = true;
    userManagement.enable = true;
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
      };
    };
  };

  services.fwupd.enable = true;

  boot.initrd = {
    # Use the modern systemd initrd path so the root LUKS volume can be
    # unlocked with a FIDO2 security key enrolled via systemd-cryptenroll.
    systemd = {
      enable = true;
      fido2.enable = true;
    };

    availableKernelModules = ["usbhid"];
    luks = {
      fido2Support = false;
      devices.crypted.crypttabExtraOpts = [
        "fido2-device=auto"
        "token-timeout=10s"
      ];
    };
  };

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"];
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

  nixpkgs.overlays = [
    (final: prev: inputs.quickshell-upstream.overlays.default final prev)
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
