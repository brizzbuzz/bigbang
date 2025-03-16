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

  # Minio service
  services.minio-server = {
    enable = true;
    port = 9002;
    consolePort = 9003;
  };

  services.grafana-server = {
    enable = true;
    domain = "metrics.rgbr.ink";
    mimir.url = "http://localhost:9009/prometheus";
  };

  lgtm.mimir = {
    enable = true;
    port = 9009;
    retentionTime = "1080h";
    storage.minio = {
      endpoint = "localhost:${toString config.services.minio-server.port}";
      bucketName = "mimir";
      region = "us-east-1";
      credentialsFile = "/var/lib/opnix/secrets/minio/lgtm-credentials";
    };
    nodeExporter = {
      enable = true;
      targets = ["localhost" "cloudy.chateaubr.ink"];
    };
  };

  lgtm.loki = {
     enable = true;
     port = 3100;
     retentionTime = "1080h"; # Same as Mimir for consistency
     storage.minio = {
       endpoint = "localhost:${toString config.services.minio-server.port}";
       bucketName = "loki";
       region = "us-east-1";
       credentialsFile = "/var/lib/opnix/secrets/minio/lgtm-credentials";
     };
   };

   lgtm.tempo = {
     enable = true;
     port = 3200;
     grpcPort = 9097;
     retentionTime = "1080h"; # Same as Mimir and Loki for consistency
     storage.minio = {
       endpoint = "localhost:${toString config.services.minio-server.port}";
       bucketName = "tempo";
       region = "us-east-1";
       credentialsFile = "/var/lib/opnix/secrets/minio/lgtm-credentials";
     };
   };

   lgtm.alloy = {
     enable = true;
     port = 12345;
     configFile = ./config.alloy;
     extraFlags = [
       "--disable-reporting"
     ];
   };

  host = {
    name = "cloudy";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;

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
            target = "gigame.chateaubr.ink:8096";
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
          mimir = {
            enable = true;
            subdomain = "mimir";
            target = "localhost:9009";
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
