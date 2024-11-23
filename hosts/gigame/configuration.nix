{inputs, ...}: {
  imports = [
    #inputs.disko.nixosModules.disko
    inputs.opnix.nixosModules.default
    ./hardware-configuration.nix
    #./disko.nix
    ../../modules/nixos
    ../../modules/home-manager
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
