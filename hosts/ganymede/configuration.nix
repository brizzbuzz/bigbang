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

  # OpNix disabled - ganymede doesn't need any secrets
  services.onepassword-secrets = {
    enable = false;
  };

  host = {
    ai.enable = true;
    name = "ganymede";
    desktop.enable = false;
    gpu.nvidia.enable = true;
    jellyfin.server.enable = true;
    keyboard = "moonlander";
    remote.enable = true;
  };

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
      "hass"
      "jellyfin"
      "openwebui"
    ];
    serviceUsers = [
      {
        name = "hass";
        database = "hass";
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
