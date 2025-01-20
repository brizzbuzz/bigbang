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

  # Create an installation script
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
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

  # Disable wireless to avoid conflict with NetworkManager
  networking = {
    wireless.enable = lib.mkForce false;
    networkmanager.enable = true;
  };

  # Enable SSH in the ISO
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Set a root password for the live system
  users.users.root.initialPassword = "cloudy";

  # Disable automatic login
  services.getty.autologinUser = lib.mkForce null;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
