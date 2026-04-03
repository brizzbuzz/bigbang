{
  config,
  lib,
  ...
}: let
  cfg = config.services.media.arr;

  mkPort = enable: port: lib.optional enable port;
  mkServiceUser = name: {
    ${name} = {
      isSystemUser = true;
      group = name;
      extraGroups = [cfg.mediaGroup];
    };
  };
  mkServiceGroup = name: {
    ${name} = {};
  };
in {
  options.services.media.arr = {
    enable = lib.mkEnableOption "Enable *arr stack services";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open *arr web ports in the firewall.";
    };

    mediaRoot = lib.mkOption {
      type = lib.types.str;
      default = "/data/media";
      description = "Root path for media libraries";
    };

    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "Shared group for media services";
    };

    services = {
      prowlarr.enable = lib.mkEnableOption "Enable Prowlarr";
      sonarr.enable = lib.mkEnableOption "Enable Sonarr";
      radarr.enable = lib.mkEnableOption "Enable Radarr";
      lidarr.enable = lib.mkEnableOption "Enable Lidarr";
      bazarr.enable = lib.mkEnableOption "Enable Bazarr";
      jellyseerr.enable = lib.mkEnableOption "Enable Jellyseerr";
    };

    ports = {
      prowlarr = lib.mkOption {
        type = lib.types.int;
        default = 9696;
        description = "Prowlarr web port";
      };
      sonarr = lib.mkOption {
        type = lib.types.int;
        default = 8989;
        description = "Sonarr web port";
      };
      radarr = lib.mkOption {
        type = lib.types.int;
        default = 7878;
        description = "Radarr web port";
      };
      lidarr = lib.mkOption {
        type = lib.types.int;
        default = 8686;
        description = "Lidarr web port";
      };
      bazarr = lib.mkOption {
        type = lib.types.int;
        default = 6767;
        description = "Bazarr web port";
      };
      jellyseerr = lib.mkOption {
        type = lib.types.int;
        default = 5055;
        description = "Jellyseerr web port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups = lib.mkMerge [
      {
        ${cfg.mediaGroup} = {};
      }
      (lib.mkIf cfg.services.prowlarr.enable (mkServiceGroup "prowlarr"))
      (lib.mkIf cfg.services.sonarr.enable (mkServiceGroup "sonarr"))
      (lib.mkIf cfg.services.radarr.enable (mkServiceGroup "radarr"))
      (lib.mkIf cfg.services.lidarr.enable (mkServiceGroup "lidarr"))
      (lib.mkIf cfg.services.bazarr.enable (mkServiceGroup "bazarr"))
      (lib.mkIf cfg.services.jellyseerr.enable (mkServiceGroup "jellyseerr"))
      (lib.mkIf config.services.media.jellyfin.enable (mkServiceGroup "jellyfin"))
      (lib.mkIf config.services.torrents.enable (mkServiceGroup "qbittorrent"))
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.mediaRoot}/movies 0775 root ${cfg.mediaGroup} -"
      "d ${cfg.mediaRoot}/tv 0775 root ${cfg.mediaGroup} -"
      "d ${cfg.mediaRoot}/music 0775 root ${cfg.mediaGroup} -"
    ];

    services.prowlarr = lib.mkIf cfg.services.prowlarr.enable {
      enable = true;
    };

    services.sonarr = lib.mkIf cfg.services.sonarr.enable {
      enable = true;
    };

    services.radarr = lib.mkIf cfg.services.radarr.enable {
      enable = true;
    };

    services.lidarr = lib.mkIf cfg.services.lidarr.enable {
      enable = true;
    };

    services.bazarr = lib.mkIf cfg.services.bazarr.enable {
      enable = true;
    };

    services.jellyseerr = lib.mkIf cfg.services.jellyseerr.enable {
      enable = true;
    };

    users.users = lib.mkMerge [
      (lib.mkIf cfg.services.prowlarr.enable (mkServiceUser "prowlarr"))
      (lib.mkIf cfg.services.sonarr.enable (mkServiceUser "sonarr"))
      (lib.mkIf cfg.services.radarr.enable (mkServiceUser "radarr"))
      (lib.mkIf cfg.services.lidarr.enable (mkServiceUser "lidarr"))
      (lib.mkIf cfg.services.bazarr.enable (mkServiceUser "bazarr"))
      (lib.mkIf cfg.services.jellyseerr.enable (mkServiceUser "jellyseerr"))
      (lib.mkIf config.services.media.jellyfin.enable (mkServiceUser "jellyfin"))
      (lib.mkIf config.services.torrents.enable (mkServiceUser "qbittorrent"))
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      mkPort cfg.services.prowlarr.enable cfg.ports.prowlarr
      ++ mkPort cfg.services.sonarr.enable cfg.ports.sonarr
      ++ mkPort cfg.services.radarr.enable cfg.ports.radarr
      ++ mkPort cfg.services.lidarr.enable cfg.ports.lidarr
      ++ mkPort cfg.services.bazarr.enable cfg.ports.bazarr
      ++ mkPort cfg.services.jellyseerr.enable cfg.ports.jellyseerr
    );
  };
}
