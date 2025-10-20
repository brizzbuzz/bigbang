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

  services.onepassword-secrets = lib.mkIf config.host.authentik.enable {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"];

    # Authentik secrets configuration
    secrets = {
      authentikEnv = {
        reference = "op://Homelab/AuthentikSecrets/notesPlain";
        path = "/var/lib/opnix/secrets/authentik/env";
        owner = "root";
        group = "root";
        mode = "0640";
        services = ["authentik" "authentik-worker" "authentik-migrate"];
      };
    };

    # Disable systemd integration to avoid circular dependencies
    # (authentik services will start independently)
    systemdIntegration = {
      enable = false;
    };
  };

  host = {
    audiobookshelf.enable = true;
    authentik.enable = true;
    name = "ganymede";
    desktop.enable = false;
    gpu.nvidia.enable = true;
    immich.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
    tandoor.enable = true;
  };

  system-limits = {
    enable = false;
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
      "tandoor"
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
        name = "tandoor";
        database = "tandoor";
      }
    ];
    initialScript = pkgs.writeText "postgresql-init.sql" ''
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
