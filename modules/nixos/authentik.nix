{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.services.authentik-homelab;
in {
  imports = [
    inputs.authentik-nix.nixosModules.default
  ];

  options.services.authentik-homelab = {
    enable = lib.mkEnableOption "homelab Authentik identity provider";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "auth.rgbr.ink";
      description = "Canonical public Authentik hostname.";
    };

    environmentSecretRef = lib.mkOption {
      type = lib.types.str;
      default = "op://Homelab/Authentik Env/notesPlain";
      description = "1Password reference for the Authentik environment file.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opnix/secrets/authentik.env";
      description = "Runtime path for the OpNix-managed Authentik environment file.";
    };

    postgresHost = lib.mkOption {
      type = lib.types.str;
      default = "192.168.11.39";
      description = "PostgreSQL host used by Authentik.";
    };

    postgresPort = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "PostgreSQL port used by Authentik.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.onepassword-secrets = {
      secrets.authentikEnv = {
        reference = cfg.environmentSecretRef;
        path = cfg.environmentFile;
        owner = "root";
        group = "root";
        mode = "0400";
        services = [
          "authentik"
          "authentik-worker"
          "authentik-migrate"
        ];
      };

      systemdIntegration.services = lib.mkAfter [
        "authentik"
        "authentik-worker"
        "authentik-migrate"
      ];
    };

    services.authentik = {
      enable = true;
      createDatabase = false;
      environmentFile = cfg.environmentFile;
      worker = {
        listenHTTP = "127.0.0.1:9001";
        listenMetrics = "127.0.0.1:9301";
      };
      settings = {
        disable_update_check = true;
        error_reporting.enabled = false;
        avatars = "initials";
        listen = {
          http = "127.0.0.1:9100";
          https = "127.0.0.1:9443";
          metrics = "127.0.0.1:9300";
          debug = "127.0.0.1:9900";
          trusted_proxy_cidrs = "127.0.0.1/32";
        };
        postgresql = {
          host = cfg.postgresHost;
          port = cfg.postgresPort;
          user = "authentik";
          name = "authentik";
        };
      };
    };

    systemd.services = {
      authentik-migrate = {
        wants = ["opnix-secrets.service"];
        after = ["opnix-secrets.service"];
      };
      authentik-worker = {
        wants = ["opnix-secrets.service"];
        after = ["opnix-secrets.service"];
      };
      authentik = {
        wants = ["opnix-secrets.service"];
        after = ["opnix-secrets.service"];
      };
    };
  };
}
