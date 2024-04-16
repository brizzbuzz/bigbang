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

  host = {
    name = "gigame";
    gpu.nvidia.enable = true;
    remote.enable = true;
  };

  system.stateVersion = "23.11";
}
