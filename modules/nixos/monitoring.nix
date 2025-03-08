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

      # Prometheus options
      prometheus = {
        enable = lib.mkEnableOption "Enable Prometheus";
        port = lib.mkOption {
          type = lib.types.int;
          default = 9090;
          description = "The port for Prometheus";
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
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://gigame.brizz.net:${toString cfg.prometheus.port}";
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
      (lib.mkIf cfg.prometheus.enable [ cfg.prometheus.port ])
      (lib.mkIf cfg.nodeExporter.enable [ cfg.nodeExporter.port ])
    ];

    # Prometheus configuration for scraping
    services.prometheus = {
      exporters.node = lib.mkIf cfg.nodeExporter.enable {
        enable = true;
        enabledCollectors = ["systemd"];
        port = cfg.nodeExporter.port;
      };
      
      # Full Prometheus server configuration
      enable = lib.mkIf cfg.prometheus.enable true;
      port = lib.mkIf cfg.prometheus.enable cfg.prometheus.port;
      
      # Default retention time (2 weeks)
      retentionTime = "14d";
      
      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "localhost:${toString cfg.nodeExporter.port}"
                "cloudy.brizz.net:${toString cfg.nodeExporter.port}"
              ];
              labels = {
                group = "production";
              };
            }
          ];
        }
      ];
    };
  };
}
