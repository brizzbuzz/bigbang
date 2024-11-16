{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/home-manager
    inputs.opnix.nixosModules.default
  ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    configFile = ./../../secrets.json;
  };

  host = {
    name = "gigame";
    keyboard = "moonlander";
    gpu.nvidia.enable = true;
    remote.enable = true;

    ai.enable = true;
  };

  system.stateVersion = "24.05";
}
