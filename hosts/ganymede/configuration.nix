{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.hyperbaric.nixosModules.default
    inputs.opnix.nixosModules.default
    inputs.spacebarchat.nixosModules.default
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/nixos
  ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    users = ["ryan"];

    secrets = {
      portfolioEnv = {
        reference = "op://Homelab/Portfolio Secrets/notesPlain";
        path = "/var/lib/opnix/secrets/hyperbaric-portfolio.env";
        owner = "root";
        group = "root";
        mode = "0600";
        services = ["portfolio"];
      };
      spacebarRequestSignature = {
        reference = "op://Homelab/Spacebar Request Signature/notesPlain";
        path = "/var/lib/opnix/secrets/spacebar-request-signature";
        owner = "spacebarchat";
        group = "spacebarchat";
        mode = "0600";
        services = ["spacebar-api" "spacebar-gateway" "spacebar-cdn"];
      };
    };

    systemdIntegration = {
      enable = true;
      services = [
        "portfolio"
        "spacebar-api"
        "spacebar-gateway"
        "spacebar-cdn"
      ];
      restartOnChange = true;
    };
  };

  host = {
    name = "ganymede";

    hardware.gpu.nvidia.enable = true;
    keyboard = "moonlander";
    roles.remote = true;
    userManagement.enable = true;
  };

  system-limits = {
    enable = false;
  };

  services.torrents = {
    enable = true;
    qbittorrent = {
      webuiUsernameSecretRef = "op://Homelab/Bittorrent Admin Password/username";
      webuiPasswordSecretRef = "op://Homelab/Bittorrent Admin Password/password";
      savePath = "/data/torrents/complete";
      tempPath = "/data/torrents/incomplete";
    };
    vpn = {
      enable = true;
      openvpnConfigSecretRef = "op://Homelab/ProtonVPN OpenVPN Ganymede/notesPlain";
      openvpnAuthSecretRef = "op://Homelab/ProtonVPN OpenVPN Ganymede Auth/notesPlain";
    };
  };

  services.portfolio = {
    enable = true;
    port = 7877;
    environmentFiles = [
      config.services.onepassword-secrets.secretPaths.portfolioEnv
    ];
  };

  services.media.immich = {
    enable = true;
  };

  services.media.jellyfin = {
    enable = true;
  };

  services.media.arr = {
    enable = true;
    services = {
      prowlarr.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      lidarr.enable = true;
      bazarr.enable = true;
      jellyseerr.enable = true;
    };
  };

  services.media.audiobookshelf = {
    enable = true;
  };

  services.clickhouse = {
    enable = true;
    passwordSha256SecretRef = "op://Homelab/Clickhouse Admin/password_sha_256";
  };

  # Spacebar: self-hosted Discord-compatible chat platform
  services.spacebarchat-server = {
    enable = true;
    serverName = "chat.rgbr.ink";

    apiEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 3001;
      publicPort = 443;
      useSsl = true;
    };
    gatewayEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 3003;
      publicPort = 443;
      useSsl = true;
    };
    cdnEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 3002;
      publicPort = 443;
      useSsl = true;
    };

    cdnPath = "/var/lib/spacebar/files";
    requestSignaturePath = "/var/lib/opnix/secrets/spacebar-request-signature";

    extraEnvironment = {
      THREADS = 1;
      DATABASE = "postgres:///spacebarchat?host=/run/postgresql";
    };

    settings = {
      security.forwardedFor = "X-Forwarded-For";
      register = {
        requireInvite = true;
        defaultRights = "875069521771520"; # default Discord-like rights minus CREATE_GUILDS
      };
    };
  };

  # Ensure CDN storage directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/spacebar/files 0750 spacebarchat spacebarchat -"
  ];

  # Allow callisto to reach Spacebar service ports
  networking.firewall.allowedTCPPorts = [3001 3002 3003];

  # Enable PostgreSQL for home lab services and development
  services.postgresql = {
    enable = true;
    developmentMode = true;
    extensions = with config.services.postgresql.package.pkgs; [
      pgvector
    ];
    serviceDatabases = [
      "immich"
      "jellyfin"
      "spacebarchat"
    ];
    serviceUsers = [
      {
        name = "immich";
        database = "immich";
      }
      {
        name = "jellyfin";
        database = "jellyfin";
      }
      {
        name = "spacebarchat";
        database = "spacebarchat";
      }
    ];
    initialScript = pkgs.writeText "postgresql-init.sql" ''
      CREATE EXTENSION IF NOT EXISTS vector;
    '';
  };

  system.stateVersion = "24.05";
}
