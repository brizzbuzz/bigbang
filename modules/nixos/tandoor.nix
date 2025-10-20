{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.tandoor;
in {
  options.host.tandoor = {
    enable = lib.mkEnableOption "Tandoor Recipes server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port for Tandoor Recipes web interface";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to bind Tandoor Recipes server";
    };

    database = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "tandoor";
        description = "Database name for Tandoor";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "tandoor";
        description = "Database user for Tandoor";
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {
        ENABLE_SIGNUP = "1";
        COMMENT_PREF_DEFAULT = "1";
        SHOPPING_MIN_AUTOSYNC_INTERVAL = "5";
        TANDOOR_PORT = toString cfg.port;
        # Essential reverse proxy settings
        ALLOWED_HOSTS = "recipes.rgbr.ink,localhost,127.0.0.1,ganymede.chateaubr.ink";
        CSRF_TRUSTED_ORIGINS = "https://recipes.rgbr.ink";
        USE_X_FORWARDED_HOST = "True";
        USE_X_FORWARDED_PROTO = "True";
      };
      description = "Extra configuration options for Tandoor";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable PostgreSQL and configure database
    services.postgresql = {
      enable = true;
      serviceDatabases = [cfg.database.name];
      serviceUsers = [
        {
          name = cfg.database.user;
          database = cfg.database.name;
        }
      ];
    };

    # Configure Tandoor service using the NixOS module
    services.tandoor-recipes = {
      enable = true;
      address = cfg.address;
      port = cfg.port;

      extraConfig =
        cfg.extraConfig
        // {
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "localhost";
          POSTGRES_PORT = "5432";
          POSTGRES_DB = cfg.database.name;
          POSTGRES_USER = cfg.database.user;
          # Password authentication not needed for local socket connections
        };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Ensure Tandoor starts after PostgreSQL
    systemd.services.tandoor-recipes = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
    };
  };
}
