{
  config,
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
        services = ["hyperbaric-portfolio"];
      };
    };

    systemdIntegration = {
      enable = true;
      services = [
        "hyperbaric-portfolio"
      ];
      restartOnChange = true;
    };
  };

  host = {
    name = "ganymede";

    gpu.nvidia.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
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
    };
    vpn = {
      enable = true;
      openvpnConfigSecretRef = "op://Homelab/ProtonVPN OpenVPN Ganymede/notesPlain";
      openvpnAuthSecretRef = "op://Homelab/ProtonVPN OpenVPN Ganymede Auth/notesPlain";
    };
  };

  services.portfolio = {
    enable = true;
    environmentFileSecrets = ["portfolioEnv"];
  };

  services.media.immich = {
    enable = true;
  };

  services.media.jellyfin = {
    enable = true;
  };

  services.media.audiobookshelf = {
    enable = true;
  };

  services.stream.sunshine = {
    enable = true;
    user = "ryan";
  };

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
    ];
    initialScript = pkgs.writeText "postgresql-init.sql" ''
      CREATE EXTENSION IF NOT EXISTS vector;
    '';
  };

  system.stateVersion = "24.05";
}
