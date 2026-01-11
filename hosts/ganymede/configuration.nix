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

  host = {
    audiobookshelf.enable = true;
    name = "ganymede";

    gpu.nvidia.enable = true;
    immich.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    portfolio.enable = true;
    remote.enable = true;
    userManagement.enable = true;
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

  # Enable PostgreSQL for home lab services and development
  services.postgresql = {
    enable = true;
    developmentMode = true;
    extraPlugins = with config.services.postgresql.package.pkgs; [
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
