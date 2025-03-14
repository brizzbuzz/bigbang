{
  config,
  lib,
  ...
}: let
  cfg = config.services.grafana-server;
in {
  options.services.grafana-server = {
    enable = lib.mkEnableOption "Enable Grafana";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "metrics.${config.host.caddy.domain or "localhost"}";
      description = "The domain name for Grafana";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "The port for Grafana";
    };

    prometheus = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString (config.services.prometheus-server.port or 9090)}";
        description = "The URL for the Prometheus data source";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Grafana configuration
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = cfg.port;
          domain = cfg.domain;
          root_url = "https://${cfg.domain}";
        };
        security = {
          # Default admin user (should be changed after first login)
          admin_user = "admin";
          admin_password = "admin";
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = cfg.prometheus.url;
            isDefault = true;
          }
        ];
      };
    };

    # Caddy reverse proxy for Grafana (if Caddy is enabled)
    services.caddy.virtualHosts = lib.mkIf config.services.caddy.enable {
      "${cfg.domain}" = {
        extraConfig = ''
          tls /etc/ssl/certs/cloudflare-cert.pem /etc/ssl/private/cloudflare-key.pem
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
