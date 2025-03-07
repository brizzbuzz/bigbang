{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    monitoring = {
      # Grafana options
      grafana = {
        enable = lib.mkEnableOption "Enable Grafana";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "metrics.${config.host.caddy.domain}";
          description = "The domain name for Grafana";
        };
        port = lib.mkOption {
          type = lib.types.int;
          default = 3000;
          description = "The port for Grafana";
        };
      };
    };
  };

  config = let
    cfg = config.monitoring;
  in {
    # Grafana configuration
    services.grafana = lib.mkIf cfg.grafana.enable {
      enable = true;
      settings = {
        server = {
          http_port = cfg.grafana.port;
          domain = cfg.grafana.domain;
          root_url = "https://${cfg.grafana.domain}";
        };
        security = {
          # Default admin user (should be changed after first login)
          admin_user = "admin";
          admin_password = "admin";
        };
      };
    };

    # Caddy reverse proxy for Grafana
    services.caddy.virtualHosts = lib.mkIf cfg.grafana.enable {
      "${cfg.grafana.domain}" = {
        extraConfig = ''
          tls /etc/ssl/certs/cloudflare-cert.pem /etc/ssl/private/cloudflare-key.pem
          reverse_proxy localhost:${toString cfg.grafana.port}
        '';
      };
    };

    # Firewall configuration for Grafana
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.grafana.enable [ cfg.grafana.port ];
  };
}