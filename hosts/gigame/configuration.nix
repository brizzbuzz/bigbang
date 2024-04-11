{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  nixos-modules,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/confused.nix
    inputs.home-manager.nixosModules.home-manager
    nixos-modules.boot
    nixos-modules.environment
    nixos-modules.flake-support
    nixos-modules.fonts
    nixos-modules.garbage-collection
    nixos-modules.hardware
    nixos-modules.hyprland
    nixos-modules.locale
    nixos-modules.networking
    nixos-modules.nvidia
    nixos-modules.polkit
    nixos-modules.users
    nixos-modules.security
    nixos-modules.xdg
    nixos-modules.xserver
  ];

  # TODO: Move to common
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ryan = import ../../profile/ryan.nix;
  home-manager.extraSpecialArgs = {
    inherit pkgs pkgs-unstable;
  };

  # Enable networking
  networking.hostName = "gigame";
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker
  virtualisation.docker.enable = true;

  # System State
  system.stateVersion = "23.11";
}
