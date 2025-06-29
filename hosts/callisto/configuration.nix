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
    users = ["ryan"]; # TODO: Read from config

    # Keep existing secrets in JSON file for gradual migration
    configFiles = [
      ./../../secrets.json
    ];

    # New declarative SSL certificate configuration
    secrets = {
      "ssl/cloudflare-cert" = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/cert";
        path = "/etc/ssl/certs/cloudflare-origin.pem";
        owner = "caddy";
        group = "caddy";
        mode = "0644";
        services = ["caddy"];
      };

      "ssl/cloudflare-key" = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/privateKey";
        path = "/etc/ssl/private/cloudflare-origin.key";
        owner = "caddy";
        group = "caddy";
        mode = "0600";
        services = ["caddy"];
      };
    };

    # Enable systemd integration for reliable service management
    systemdIntegration = {
      enable = true;
      services = ["caddy"];
      restartOnChange = true;
    };
  };

  # Create SSL directories for OpNix-managed certificates
  systemd.tmpfiles.rules = [
    "d /etc/ssl/certs 0755 root root -"
    "d /etc/ssl/private 0700 root root -"
  ];

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
  };

  lgtm.node_exporter = {
    enable = true;
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
    name = "callisto";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;

    caddy = {
      enable = true;
      domain = "rgbr.ink";
      sites = {
        root = {
          enable = true;
          content = "Hello from callisto!";
        };
        proxies = {
          media = {
            enable = true;
            subdomain = "media";
            target = "ganymede.chateaubr.ink:8096";
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
          ollama = {
            enable = true;
            subdomain = "ollama";
            target = "ganymede.chateaubr.ink:11434";
            logLevel = "INFO";
          };
          ai = {
            enable = true;
            subdomain = "ai";
            target = "ganymede.chateaubr.ink:11435";
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
