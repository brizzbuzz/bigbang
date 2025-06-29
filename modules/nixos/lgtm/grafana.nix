{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.grafana-server;

  # Dashboard directory
  dashboardsDir = ./dashboards;
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

    loki = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString (config.lgtm.loki.port or 3100)}";
        description = "The URL for the Loki data source";
      };
    };

    tempo = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString (config.lgtm.tempo.port or 3200)}";
        description = "The URL for the Tempo data source";
      };
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = config.lgtm.tempo.enable or false;
        description = "Whether to enable the Tempo data source";
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

        # Default homepage and dashboard settings
        dashboards = {
          default_home_dashboard_path = "${dashboardsDir}/home-overview.json";
        };

        # Customize preferences for default org
        preferences = {
          # Default home dashboard with the UID from your dashboard JSON
          home_dashboard = "home-overview";
        };
      };

      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Mimir";
              type = "prometheus";
              access = "proxy";
              url = cfg.mimir.url;
              isDefault = true;
              jsonData = {
                timeInterval = "15s";
                httpHeaderName1 = "X-Scope-OrgID";
                prometheusType = "Mimir";
              };
              secureJsonData = {
                httpHeaderValue1 = "tenant1";
              };
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = cfg.loki.url;
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID";
                maxLines = 1000;
              };
              secureJsonData = {
                httpHeaderValue1 = "tenant1";
              };
            }
            {
              name = "Tempo";
              type = "tempo";
              access = "proxy";
              url = cfg.tempo.url;
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID";
                nodeGraph = {
                  enabled = true;
                };
                tracesToLogs = {
                  datasourceUid = "Loki";
                  tags = ["job" "instance" "pod" "namespace"];
                  spanStartTimeShift = "1h";
                  spanEndTimeShift = "1h";
                };
              };
              secureJsonData = {
                httpHeaderValue1 = "tenant1";
              };
            }
          ];
        };

        # Dashboard provisioning
        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "Default";
              type = "file";
              folder = "";
              options.path = dashboardsDir;
              allowUiUpdates = true;
              updateIntervalSeconds = 30;
              # Mark the first dashboard as default (will be marked with a star)
              options.foldersFromFilesStructure = true;
            }
          ];
        };
      };
    };

    # Caddy reverse proxy for Grafana (if Caddy is enabled)
    services.caddy.virtualHosts = lib.mkIf config.services.caddy.enable {
      "${cfg.domain}" = {
        extraConfig = ''
          tls ${config.services.onepassword-secrets.secretPaths.sslCloudflareCert} ${config.services.onepassword-secrets.secretPaths.sslCloudflareKey}
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
