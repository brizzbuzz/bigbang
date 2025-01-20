{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    # Import common modules
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
  };

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

  # Include some useful tools for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    parted
    gptfdisk
    cryptsetup
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
