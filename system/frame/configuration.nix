{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
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

  networking.hostName = "frame"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  system.stateVersion = "23.11";
}
