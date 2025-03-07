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
      
      # Mimir options
      mimir = {
        enable = lib.mkEnableOption "Enable Mimir metric collector";
        port = lib.mkOption {
          type = lib.types.int;
          default = 9009;
          description = "The port for Mimir";
        };
      };
      
      # Node exporter options
      nodeExporter = {
        enable = lib.mkEnableOption "Enable Prometheus Node Exporter";
        port = lib.mkOption {
          type = lib.types.int;
          default = 9100;
          description = "The port for Node Exporter";
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
      
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Mimir";
            type = "prometheus";
            access = "proxy";
            url = "http://gigame.brizz.net:${toString cfg.mimir.port}/api/v1/prometheus";
            isDefault = true;
          }
        ];
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

    # Firewall configuration
    networking.firewall.allowedTCPPorts = lib.mkMerge [
      (lib.mkIf cfg.grafana.enable [ cfg.grafana.port ])
      (lib.mkIf cfg.mimir.enable [ cfg.mimir.port ])
      (lib.mkIf cfg.nodeExporter.enable [ cfg.nodeExporter.port ])
    ];
    
    # Mimir configuration with minimal settings
    services.mimir = lib.mkIf cfg.mimir.enable {
      enable = true;
      # Absolutely minimal configuration
      configuration = {
        target = "all";
        server.http_listen_port = cfg.mimir.port;
      };
    };
    
    # Prometheus Node Exporter
    services.prometheus.exporters.node = lib.mkIf cfg.nodeExporter.enable {
      enable = true;
      enabledCollectors = ["systemd"];
      port = cfg.nodeExporter.port;
    };
  };
}