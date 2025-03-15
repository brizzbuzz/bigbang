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

    mimir = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString (config.lgtm.mimir.port or 9009)}/prometheus";
        description = "The URL for the Mimir data source";
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
      };

      provision = {
        enable = true;
        datasources.settings = {
          datasources = [
            {
              name = "Mimir";
              type = "prometheus";
              access = "proxy";
              url = "http://localhost:${toString config.lgtm.mimir.port}/prometheus";
              isDefault = true;
              # editable = true;
              jsonData = {
                timeInterval = "15s";
                httpHeaderName1 = "X-Scope-OrgID";
                prometheusType = "Mimir";
              };
              secureJsonData = {
                httpHeaderValue1 = "tenant1";
              };
            }
          ];
        };
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
