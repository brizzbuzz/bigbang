{lib, ...}: {
    fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3FDC-0BDA";
      fsType = "vfat";
      options = [
        "defaults"
        "relatime"
        "fmask=0022"
        "dmask=0022"
        "codepage=437"
        "iocharset=iso8859-1"
        "shortname=mixed"
        "errors=remount-ro"
      ];
    };

    "/nix/store" = {
      device = "/dev/disk/by-label/nix-store";
      fsType = "ext4";
      options = [ "ro" "relatime" "noatime" ];
    };
  };

  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "512M";
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"; # EFI
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "relatime"
                  "fmask=0022"
                  "dmask=0022"
                  "codepage=437"
                  "iocharset=iso8859-1"
                  "shortname=mixed"
                  "errors=remount-ro"
                ];
              };
            };
            nix-store = {
              name = "nix-store";
              size = "150G";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = ["-L" "nix-store"];
                mountpoint = "/nix/store";
                mountOptions = ["defaults" "ro" "noatime"];
              };
            };
            nixos = {
              name = "nixos";
              size = "100%";  # Use remaining space
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = ["defaults" "relatime"];
              };
            };
          };
        };
      };
    };
  };
}
