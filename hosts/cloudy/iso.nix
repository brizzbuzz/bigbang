# hosts/cloudy/iso.nix
{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/common
  ];

  # Set host configuration
  host = {
    name = "cloudy-installer";
    desktop.enable = false;
    remote.enable = true;
  };

  # ISO-specific configurations
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    isoName = "cloudy-nixos.iso";
    volumeID = "CLOUDY_NIXOS";
    # Include the entire repo in the ISO
    contents = [
      {
        source = ./../..;
        target = "/bigbang";
      }
    ];
  };

  # Essential services for installation
  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    getty = {
      autologinUser = lib.mkForce "root";
    };
  };

  # Create an installation script
  environment = {
    systemPackages = with pkgs; [
      git
      vim
      wget
      curl
      parted
      gptfdisk
      cryptsetup
      (writeScriptBin "install-cloudy" ''
        #!${pkgs.stdenv.shell}
        set -e

        echo "Starting Cloudy installation..."

        # Apply disko configuration
        echo "Partitioning drives..."
        nix run github:nix-community/disko -- --mode disko /bigbang/hosts/cloudy/disko.nix

        # Mount the partitions (adjust based on your disko config)
        echo "Mounting partitions..."
        mount /dev/disk/by-label/nixos /mnt
        mkdir -p /mnt/boot
        mount /dev/disk/by-label/boot /mnt/boot

        # Install NixOS
        echo "Installing Cloudy..."
        nixos-install --flake /bigbang#cloudy --no-root-passwd

        echo "Installation complete! You can now reboot."
      '')
    ];
  };

  # Network configuration
  networking = {
    wireless.enable = lib.mkForce false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Initial user setup with password to allow login
  users.users.root.initialPassword = "cloudy";

  # Essential system configuration
  boot = {
    kernelParams = [
      "console=tty0" # Enable console output to display
      "console=ttyS0,115200" # Enable serial console
    ];
    loader.timeout = 10; # Longer timeout for boot menu
  };

  # Allow unfree packages that might be needed during installation
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ "root" ];
  };

  # Recovery options
  users.mutableUsers = true;

  # Enable cross-compilation support
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

  # System message
  system.stateVersion = "24.05";
}
