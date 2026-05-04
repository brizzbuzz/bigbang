{
  config,
  inputs,
  pkgs,
  ...
}: let
  githubKnownHosts = [
    "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
  ];
  ryanAuthKey = "op://Homelab/Ganymede Ryan Auth Key";
  ryanSigningKey = "op://Homelab/Ganymede Ryan Signing Key";
  odysseyAuthKey = "op://Homelab/Ganymede Odyssey Auth Key";
  odysseySigningKey = "op://Homelab/Ganymede Odyssey Signing Key";
in {
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
    users = [];

    secrets = {
      portfolioEnv = {
        reference = "op://Homelab/Portfolio Secrets/notesPlain";
        path = "/var/lib/opnix/secrets/hyperbaric-portfolio.env";
        owner = "root";
        group = "root";
        mode = "0600";
        services = ["portfolio"];
      };
      spacebarJwtSecret = {
        reference = "op://Homelab/Spacebar JWT Secret/notesPlain";
        path = "/var/lib/opnix/secrets/spacebar-jwt-secret";
        owner = "spacebarchat";
        group = "spacebarchat";
        mode = "0600";
        services = ["spacebar-api" "spacebar-gateway" "spacebar-cdn"];
      };
      spacebarRequestSignature = {
        reference = "op://Homelab/Spacebar Request Signature/notesPlain";
        path = "/var/lib/opnix/secrets/spacebar-request-signature";
        owner = "spacebarchat";
        group = "spacebarchat";
        mode = "0600";
        services = ["spacebar-api" "spacebar-gateway" "spacebar-cdn"];
      };
      kagiApiKey = {
        reference = "op://Homelab/Kagi Api Key/notesPlain";
        path = "/var/lib/opnix/secrets/kagi-api-key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      netbirdHomelabHeadlessSetupKey = {
        reference = "op://Homelab/Netbird Homelab Headless Setup Key/password";
        path = "/var/lib/opnix/secrets/netbird-homelab-headless-setup-key";
        owner = "root";
        group = "root";
        mode = "0400";
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
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
      };
      odyssey = {
        name = "odyssey";
        profile = "company";
        isPrimary = false;
        containerRuntime.docker.enable = true;
      };
    };
    profiles = {
      personal = {
        developmentApps = true;
        entertainmentApps = false;
        personalApps = false;
      };
      company = {
        businessApps = false;
        developmentApps = true;
        restrictedApps = false;
      };
    };
  };

  system-limits = {
    enable = false;
  };

  services.torrents = {
    enable = true;
    qbittorrent = {
      webuiPort = 18080;
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

  services.netbird.package = pkgs.netbird-client;
  services.netbird.clients.personal = {
    port = 51820;
    autoStart = true;
    openFirewall = true;
    login = {
      enable = true;
      setupKeyFile = "/var/lib/opnix/secrets/netbird-homelab-headless-setup-key";
      systemdDependencies = ["opnix-secrets.service"];
    };
    environment = {
      NB_ADMIN_URL = "https://netbird.rgbr.ink";
      NB_MANAGEMENT_URL = "https://netbird.rgbr.ink";
    };
    config = {
      AdminURL = {
        Scheme = "https";
        Host = "netbird.rgbr.ink:443";
      };
      ManagementURL = {
        Scheme = "https";
        Host = "netbird.rgbr.ink:443";
      };
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
    openFirewall = true;
  };

  services.media.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.media.arr = {
    enable = true;
    openFirewall = true;
    mediaRoot = "/data/media";
    services = {
      prowlarr.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      lidarr.enable = true;
      bazarr.enable = true;
      seerr.enable = true;
    };
  };

  services.media.audiobookshelf = {
    enable = true;
    openFirewall = true;
  };

  services.opencode.instances = {
    ryan = {
      enable = true;
      user = "ryan";
      group = "ryan";
      bindAddress = "192.168.11.39";
      port = 4096;
      openFirewall = true;
      enableKagi = true;
      enableServerAuth = false;
      stateRoot = "/home/ryan";
      workspaceRoot = "/home/ryan/Workspace";
      workspaceNamespaces = ["github"];
      gitName = "Ryan Brink";
      gitEmail = "dev@ryanbr.ink";
      gitSignCommits = true;
      sshPrivateKeySecretRef = "${ryanAuthKey}/private key";
      sshPublicKeySecretRef = "${ryanAuthKey}/public key";
      sshSigningPrivateKeySecretRef = "${ryanSigningKey}/private key";
      sshSigningPublicKeySecretRef = "${ryanSigningKey}/public key";
      sshKnownHosts = githubKnownHosts;
    };
    odyssey = {
      enable = true;
      user = "odyssey";
      group = "odyssey";
      bindAddress = "192.168.11.39";
      port = 4097;
      openFirewall = true;
      enableKagi = true;
      enableServerAuth = false;
      stateRoot = "/home/odyssey";
      workspaceRoot = "/home/odyssey/Workspace";
      workspaceNamespaces = ["github"];
      gitName = "Ryan Brink";
      gitEmail = "ryan@withodyssey.com";
      gitSignCommits = true;
      sshPrivateKeySecretRef = "${odysseyAuthKey}/private key";
      sshPublicKeySecretRef = "${odysseyAuthKey}/public key";
      sshSigningPrivateKeySecretRef = "${odysseySigningKey}/private key";
      sshSigningPublicKeySecretRef = "${odysseySigningKey}/public key";
      sshKnownHosts = githubKnownHosts;
      extraConfig = {
        mcp = {
          datadog = {
            type = "remote";
            url = "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp?toolsets=all";
            enabled = true;
          };
          notion = {
            type = "remote";
            url = "https://mcp.notion.com/mcp";
            enabled = true;
          };
        };
      };
    };
  };

  services.clickhouse = {
    enable = true;
    openFirewall = true;
    tcpPort = 19000;
    passwordSha256SecretRef = "op://Homelab/Clickhouse Admin/password_sha_256";
  };

  # Spacebar: self-hosted Discord-compatible chat platform
  services.spacebarchat-server = {
    enable = true;
    serverName = "chat.rgbr.ink";
    legacyJwtSecretPath = "/var/lib/opnix/secrets/spacebar-jwt-secret";

    apiEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 13001;
      publicPort = 443;
      useSsl = true;
    };
    gatewayEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 13003;
      publicPort = 443;
      useSsl = true;
    };
    cdnEndpoint = {
      host = "chat.rgbr.ink";
      localPort = 13002;
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
      cdn.imagorServerUrl = "https://chat.rgbr.ink/imageproxy";
      general = {
        instanceName = "Waystone Inn";
        instanceDescription = "Name's Kvothe. I keep a quiet inn, and tell the loudest stories to friends who know how to listen.";
      };
      limits.rate = {
        enabled = true;
        ip = {
          count = 500;
          window = 5;
        };
        global = {
          count = 250;
          window = 5;
        };
        error = {
          count = 10;
          window = 5;
        };
        routes.auth.login = {
          count = 5;
          window = 60;
        };
        routes.auth.register = {
          count = 2;
          window = 43200;
        };
      };
      security.forwardedFor = "X-Forwarded-For";
      register = {
        requireInvite = true;
        defaultRights = "875069521771520"; # default Discord-like rights minus CREATE_GUILDS
        password = {
          required = true;
          minLength = 8;
          minNumbers = 1;
          minUpperCase = 1;
        };
      };
    };
  };

  # Ensure CDN storage directory exists
  systemd.tmpfiles.rules = [
    "d /data/backups/opencode 0750 root root -"
    "d /var/lib/spacebar/files 0750 spacebarchat spacebarchat -"
    "d /data/backups/spacebar 0750 postgres postgres -"
  ];

  systemd.services.opnix-secrets = {
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wants = [
      "network-online.target"
      "nss-lookup.target"
    ];
  };

  systemd.services.spacebar-backup = let
    pgDump = "${config.services.postgresql.package}/bin/pg_dump";
    date = "${pkgs.coreutils}/bin/date";
    install = "${pkgs.coreutils}/bin/install";
    find = "${pkgs.findutils}/bin/find";
    tar = "${pkgs.gnutar}/bin/tar";
  in {
    description = "Spacebar weekly backups";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
    };
    script = ''
      set -euo pipefail

      backupDir=/data/backups/spacebar
      timestamp="$(${date} -u +%Y%m%d-%H%M%S)"
      dbDump="$backupDir/spacebar-$timestamp.dump"
      cdnArchive="$backupDir/spacebar-cdn-$timestamp.tar.gz"

      ${install} -d -m 0750 -o postgres -g postgres "$backupDir"
      ${pgDump} -Fc spacebarchat > "$dbDump"
      ${tar} -czf "$cdnArchive" -C /var/lib/spacebar files

      ${find} "$backupDir" -type f -name "spacebar-*.dump" -mtime +56 -delete
      ${find} "$backupDir" -type f -name "spacebar-cdn-*.tar.gz" -mtime +56 -delete
    '';
  };

  systemd.timers.spacebar-backup = {
    description = "Weekly Spacebar backups";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sat *-*-* 03:00:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  # Keep Spacebar backend ports reachable for the public and internal chat proxies.
  networking.firewall.allowedTCPPorts = [7877 13001 13002 13003];

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
