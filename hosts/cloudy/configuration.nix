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
    tokenFile = "/etc/opnix-token";
    configFile = ./../../secrets.json;
    users = ["ryan"]; # TODO: Read from config
  };

  # New Minio service
  services.minio-server = {
    enable = true;
    port = 9002;
    consolePort = 9003;
  };

  # New Grafana service
  services.grafana-server = {
    enable = true;
    domain = "metrics.rgbr.ink";
  };

  # New Prometheus service
  services.prometheus-server = {
    enable = true;
    nodeExporter = {
      enable = true;
      targets = ["localhost" "cloudy.brizz.net"];
    };
  };

  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
    # Remove minio settings

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
          homeassistant = {
            enable = true;
            subdomain = "home";
            target = "localhost:8123";
            logLevel = "DEBUG";
          };
          minio = {
            enable = true;
            subdomain = "storage";
            target = "localhost:${toString config.services.minio-server.consolePort}";
            logLevel = "INFO";
          };
        };
      };
    };
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;
  services.home-assistant.enable = true;

  system.stateVersion = "24.05";
}
