{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/nixos
    ../../modules/home-manager
    inputs.home-manager.nixosModules.home-manager
  ];

  # TODO: Move to separate module... but seems to not work when not enabled here
  services.jellyfin = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    jellyfin.server.enable = true;
  };

  soft-serve.enable = true;

  system.stateVersion = "24.05";
}
