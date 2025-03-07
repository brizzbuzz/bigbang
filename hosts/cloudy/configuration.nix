{
  inputs,
  pkgs,
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
    tokenFile = "/etc/opnix-token";
    configFile = ./../../secrets.json;
    users = ["ryan"]; # TODO: Read from config
  };

  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
    minio.server.enable = true;

    caddy = {
      enable = true;
      domain = "rgbr.ink";
    };
  };

  # TODO: Make configurable module
  networking = {
    useDHCP = false;
    interfaces.enp100s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.50";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
    nameservers = ["8.8.8.8" "8.8.4.4"];
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;

  system.stateVersion = "24.05";
}
