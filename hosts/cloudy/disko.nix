{lib, ...}: {
  # Use mkForce to override the filesystems defined in hardware-configuration.nix
  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-uuid/c7d72a73-dd87-46f4-83df-38bfc42c8d6c";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/52E8-29D0";
      fsType = "vfat";
    };

    "/nix/store" = {
      device = "/dev/disk/by-uuid/c7d72a73-dd87-46f4-83df-38bfc42c8d6c";
      fsType = "ext4";
      options = [ "ro" "relatime" ];
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
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"; # EFI System Partition
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
            root = {
              name = "root";
              size = "100%";
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
