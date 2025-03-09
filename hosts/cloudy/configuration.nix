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
      sites = {
        root = {
          enable = true;
          content = "Hello from cloudy!";
        };
        proxies = {
          media = {
            enable = true;
            subdomain = "media";
            target = "gigame.brizz.net:8096";
            logLevel = "DEBUG";
          };
          # Use a custom home-assistant specific configuration
          homeassistant = {
            enable = true;
            subdomain = "home";
            target = "localhost:8123";
            logLevel = "DEBUG"; # Set to DEBUG temporarily to troubleshoot
          };
        };
      };
    };
  };
  
  # Enable Grafana and Node Exporter on this host
  monitoring = {
    grafana.enable = true;
    nodeExporter.enable = true;
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
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;
  services.home-assistant.enable = true;

  system.stateVersion = "24.05";
}
