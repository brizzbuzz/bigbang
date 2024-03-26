{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/1password.nix
    ../common/boot.nix
    ../common/environment.nix
    ../common/flake-support.nix
    ../common/fonts.nix
    ../common/garbage-collection.nix
    ../common/hardware.nix
    ../common/hyprland.nix
    ../common/locale.nix
    ../common/networking.nix
    ../common/users.nix
    ../common/xserver.nix
  ];

  # Enable networking
  networking.hostName = "frame";
  networking.networkmanager.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  # Finger Print Reader
  services.fprintd.enable = true;

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

  system.stateVersion = "23.11";
}
