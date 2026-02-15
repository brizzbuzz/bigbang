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
    audiobookshelf.enable = true;
    name = "ganymede";

    gpu.nvidia.enable = true;
    immich.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    portfolio = {
      enable = true;
      environmentFileSecrets = ["portfolioEnv"];
    };
    remote.enable = true;
    sunshine.enable = true;
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
