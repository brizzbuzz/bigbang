{
  config,
  inputs,
  lib,
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

  # OpNix configuration for secrets management
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"];

    # Authentik secrets configuration
    secrets = {
      authentikEnv = {
        reference = "op://Homelab/Authentik/notesPlain";
        path = "/var/lib/opnix/secrets/authentik/env";
        owner = "root";
        group = "authentik";
        mode = "0640";
        services = ["authentik" "authentik-worker" "authentik-migrate"];
      };
    };

    # Enable systemd integration for reliable service management
    systemdIntegration = {
      enable = true;
      services = ["authentik" "authentik-worker" "authentik-migrate"];
      restartOnChange = true;
    };
  };

  host = {
    ai.enable = true;
    audiobookshelf.enable = true;
    authentik.enable = true;
    name = "ganymede";
    desktop.enable = false;
    gpu.nvidia.enable = true;
    immich.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
  };

  # Enable increased system limits for heavy service workloads
  system-limits = {
    enable = true;
    fileDescriptors = 131072; # 128K file descriptors
    processes = 65536; # 64K processes
  };

  # Enable increased system limits for heavy service workloads
  system-limits = {
    enable = true;
    fileDescriptors = 131072; # 128K file descriptors
    processes = 65536; # 64K processes
  };

  # qBittorrent configuration (traffic routed via UniFi VPN policies)
  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    torrentingPort = 6881;
    openFirewall = true;
    extraArgs = ["--confirm-legal-notice"];
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          LocalHostAuth = true;
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "127.0.0.1, ::1, 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8";
        };
        Downloads = {
          SavePath = "/srv/torrents/complete";
          TempPathEnabled = true;
          TempPath = "/srv/torrents/incomplete";
        };
        Connection = {
          PortRangeMin = 6881;
          PortRangeMax = 6889;
          UPnP = false;
          RandomPort = true;
        };
        BitTorrent = {
          Encryption = 1;
          AnonymousMode = true;
        };
      };
    };
  };

  # Create torrent directories
  systemd.tmpfiles.rules = [
    "d /srv/torrents 0755 qbittorrent qbittorrent -"
    "d /srv/torrents/complete 0755 qbittorrent qbittorrent -"
    "d /srv/torrents/incomplete 0755 qbittorrent qbittorrent -"
  ];

  # Enable Home Assistant (moved from callisto for better proxy setup)
  services.home-assistant.enable = true;

  # Enable PostgreSQL for home lab services and development
  services.postgresql = {
    enable = true;
    developmentMode = true;
    extraPlugins = with config.services.postgresql.package.pkgs; [
      pgvector
    ];
    serviceDatabases = [
      "authentik"
      "hass"
      "immich"
      "jellyfin"
      "openwebui"
    ];
    serviceUsers = [
      {
        name = "authentik";
        database = "authentik";
      }
      {
        name = "hass";
        database = "hass";
      }
      {
        name = "immich";
        database = "immich";
      }
      {
        name = "jellyfin";
        database = "jellyfin";
      }
      {
        name = "openwebui";
        database = "openwebui";
      }
    ];
    initialScript = pkgs.writeText "postgresql-init.sql" ''
      CREATE EXTENSION IF NOT EXISTS vector;

      -- Grant permissions for openwebui user
      \c openwebui;
      ALTER DATABASE openwebui OWNER TO openwebui;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO openwebui;
      GRANT USAGE, CREATE ON SCHEMA public TO openwebui;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO openwebui;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO openwebui;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO openwebui;

      CREATE EXTENSION IF NOT EXISTS vector;
    '';
  };

  lgtm.alloy = {
    enable = true;
    port = 12345;
    configFile = ./config.alloy;
    extraFlags = [
      "--disable-reporting"
    ];
  };

  lgtm.node_exporter = {
    enable = true;
    enableGpuMetrics = true; # Enable GPU metrics collection
  };

  # Configure Home Assistant to use PostgreSQL
  services.home-assistant.config.recorder = {
    db_url = "postgresql://hass@localhost/hass";
    purge_keep_days = 30;
    commit_interval = 5;
  };

  # Disable OpNix for Home Manager since system-level OpNix is disabled
  home-manager.users.${config.host.admin.name} = {
    programs.onepassword-secrets.enable = lib.mkForce false;
  };

  system.stateVersion = "24.05";
}
