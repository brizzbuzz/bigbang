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
    ai.enable = true;
    name = "gigame";
    desktop.enable = false;
    gpu.nvidia.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
  };

  lgtm.alloy = {
    enable = true;
    port = 12345;
    mimirTarget = "http://cloudy.brizz.net:9009/prometheus/api/v1/push";
    #nodeExporter.enable = true;
    #nvidia.enable = true;
    #selfMonitoring.enable = true;
  };

  # TODO: Make configurable module
  networking = {
    useDHCP = false;
    interfaces.enp4s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.51";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
  };

  system.stateVersion = "24.05";
}
