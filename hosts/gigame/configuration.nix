{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.opnix.nixosModules.default
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/nixos
    ../../modules/home-manager
  ];

  services.onepassword-secrets = {
    enable = true;
    users = [config.host.admin.name];
    tokenFile = "/etc/opnix-token";
    configFile = ./../../secrets.json;
  };

  host = {
    name = "gigame";
    keyboard = "moonlander";
    gpu.nvidia.enable = true;
    desktop.enable = false;
    remote.enable = true;

    ai.enable = true;
  };

  # TODO: Make configurable module
  networking = {
    useDHCP = false;
    interfaces.enp4s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.1.51";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };

  system.stateVersion = "24.05";
}
