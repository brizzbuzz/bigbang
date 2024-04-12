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
    ../../modules/home-manager
  ];

  host.name = "gigame";
  host.gpu.nvidia.enable = true;

  system.stateVersion = "23.11";
}
