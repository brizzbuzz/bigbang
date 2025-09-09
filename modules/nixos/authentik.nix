{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.host.authentik;
in {
  imports = [
    inputs.authentik-nix.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    services.authentik = {
      enable = true;
      environmentFile = config.services.onepassword-secrets.secretPaths.authentikEnv;
      settings = {
        web = {
          listen = "0.0.0.0";
          port = cfg.port;
        };
        disable_startup_analytics = true;
        avatars = "initials";
        log_level = "info";

        # Database configuration
        postgresql = {
          host = "/run/postgresql";
          name = "authentik";
          user = "authentik";
          port = 5432;
        };

        # Redis configuration
        redis = {
          host = "127.0.0.1";
          port = 6379;
        };

        # Disable outpost features that might cause panic
        outposts = {
          disable_embedded_outpost = true;
        };

        # Trusted proxy configuration for reverse proxy
        listen = {
          trusted_proxy_ips = ["192.168.11.0/24" "127.0.0.1/32"];
        };

        # Set proper domain for reverse proxy access
        authentik = {
          cookie_domain = "auth.rgbr.ink";
        };
      };
    };

    # Enable Redis for Authentik
    services.redis.servers.authentik = {
      enable = true;
      port = 6379;
      bind = "127.0.0.1";
      settings = {
        maxmemory = "256mb";
        maxmemory-policy = "allkeys-lru";
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
