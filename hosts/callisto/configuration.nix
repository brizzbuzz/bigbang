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

    # Fully declarative secrets configuration
    secrets = {
      # SSL certificates for Caddy
      sslCloudflareCert = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/cert";
        path = "/var/lib/caddy/ssl/cloudflare-origin.pem";
        owner = "caddy";
        group = "caddy";
        mode = "0644";
        services = ["caddy"];
      };

      sslCloudflareKey = {
        reference = "op://Homelab/Cloudflare Origin Certs/rgbr.ink/privateKey";
        path = "/var/lib/caddy/ssl/cloudflare-origin.key";
        owner = "caddy";
        group = "caddy";
        mode = "0600";
        services = ["caddy"];
      };

      # Atticd server environment
      atticdServerEnv = {
        reference = "op://Homelab/Atticd/notesPlain";
        path = "/var/lib/opnix/secrets/atticd/server/env";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # Minio credentials
      minioRootCredentials = {
        reference = "op://Homelab/Minio Root Credentials/notesPlain";
        path = "/var/lib/opnix/secrets/minio/root-credentials";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      minioLgtmCredentials = {
        reference = "op://Homelab/Minio LGTM Credentials/notesPlain";
        path = "/var/lib/opnix/secrets/minio/lgtm-credentials";
        owner = "root";
        group = "root";
        mode = "0600";
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
    "d /var/lib/caddy/ssl 0750 caddy caddy -"
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
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
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
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
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
      credentialsFile = config.services.onepassword-secrets.secretPaths.minioLgtmCredentials;
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

  system-limits = {
    enable = false;
  };

  host = {
    name = "callisto";
    desktop.enable = false;
    remote.enable = true;
    attic.server.enable = true;
    blocky = {
      enable = true;
      customDNS.enable = false; # UniFi handles local domain resolution
      blocking = {
        enable = true;
        clientGroups = {
          default = ["ads" "malware" "tracking"];
          kids = ["ads" "malware" "tracking"];
        };
      };
      caching = {
        enable = true;
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
      logLevel = "info";
    };

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
            target = "ganymede.chateaubr.ink:8123";
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
          ai = {
            enable = true;
            subdomain = "ai";
            target = "ganymede.chateaubr.ink:11435";
            logLevel = "INFO";
          };
          torrents = {
            enable = true;
            subdomain = "torrents";
            target = "ganymede.chateaubr.ink:8080";
            logLevel = "INFO";
          };
          blocky = {
            enable = true;
            subdomain = "dns";
            target = "localhost:4000";
            logLevel = "INFO";
          };
          photos = {
            enable = true;
            subdomain = "photos";
            target = "ganymede.chateaubr.ink:2283";
            logLevel = "INFO";
          };
          books = {
            enable = true;
            subdomain = "books";
            target = "ganymede.chateaubr.ink:13378";
            logLevel = "INFO";
          };
          auth = {
            enable = true;
            subdomain = "auth";
            target = "ganymede.chateaubr.ink:9000";
            logLevel = "INFO";
          };
        };
      };
    };
  };

  glance.enable = true;
  soft-serve.enable = true;
  speedtest.enable = true;
  # services.home-assistant.enable = true; # Moved to ganymede

  system.stateVersion = "24.05";
}
