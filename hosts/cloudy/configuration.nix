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

  host.name = "cloudy";
  host.admin.name = "god";
  host.desktop.enable = false;
  host.remote.enable = true;

  # TODO: Should I disable this on all hosts?
  systemd.services.NetworkManager-wait-online.enable = false;

  system.stateVersion = "23.11";
}
