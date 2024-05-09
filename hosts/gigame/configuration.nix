{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/home-manager
  ];

  host = {
    name = "gigame";
    keyboard = "moonlander";
    gpu.nvidia.enable = true;
    remote.enable = true;
  };

  system.stateVersion = "23.11";
}
