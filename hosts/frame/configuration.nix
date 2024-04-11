{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.home-manager
  ];

  host = {
    name = "frame";
    admin.name = "ryan";
  };

  # TODO: Move to common
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ryan = import ../../profile/ryan.nix;
  home-manager.extraSpecialArgs = {
    inherit pkgs pkgs-unstable;
  };

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
