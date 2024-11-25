{...}: {
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            swap = {
              name = "swap";
              priority = 2;
              size = "32G";
              content = {
                type = "swap";
                resumeDevice = true;  # Enables hibernation
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];  # Force creation
                subvolumes = {
                  # Subvolume for root filesystem
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Subvolume for nix store
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Subvolume for home directories
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Subvolume for state that persists across system updates
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Subvolume for system state that should be wiped on boot
                  "/tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              name = "data";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "/data" = {
                    mountpoint = "/data";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Games directory with no compression for better performance
                  "/games" = {
                    mountpoint = "/data/games";
                    mountOptions = ["noatime"];
                  };
                  # Media directory with compression
                  "/media" = {
                    mountpoint = "/data/media";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
