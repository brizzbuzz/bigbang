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

    oauth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable OAuth authentication";
      };

      authentik = {
        authUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://auth.${config.host.caddy.domain}/application/o/authorize/";
          description = "The OAuth authorization URL";
        };

        tokenUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://auth.${config.host.caddy.domain}/application/o/token/";
          description = "The OAuth token URL";
        };

        apiUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://auth.${config.host.caddy.domain}/application/o/userinfo/";
          description = "The OAuth API URL for user info";
        };

        allowedDomains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of allowed email domains";
        };
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

        # OAuth configuration
        "auth.generic_oauth" = lib.mkIf cfg.oauth.enable {
          enabled = true;
          name = "Authentik";
          allow_sign_up = true;
          client_id = "$__file{${config.services.onepassword-secrets.secretPaths.grafanaOAuthClientId}}";
          client_secret = "$__file{${config.services.onepassword-secrets.secretPaths.grafanaOAuthClientSecret}}";
          scopes = "openid profile email";
          empty_scopes = false;
          auth_url = cfg.oauth.authentik.authUrl;
          token_url = cfg.oauth.authentik.tokenUrl;
          api_url = cfg.oauth.authentik.apiUrl;
          allowed_domains = lib.concatStringsSep " " cfg.oauth.authentik.allowedDomains;
          allow_assign_grafana_admin = true;
          auto_login = false;
          role_attribute_path = "contains(groups[*], 'authentik Admins') && 'GrafanaAdmin' || 'Admin'";
        };

        # Disable other auth methods when OAuth is enabled
        "auth.anonymous" = lib.mkIf cfg.oauth.enable {
          enabled = false;
        };

        "auth.basic" = lib.mkIf cfg.oauth.enable {
          enabled = false;
        };

        # Disable login form when OAuth is enabled
        "auth" = lib.mkIf cfg.oauth.enable {
          disable_login_form = true;
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

    # Create secrets directory for OAuth files when OAuth is enabled
    systemd.tmpfiles.rules = lib.mkIf cfg.oauth.enable [
      "d /var/lib/grafana/secrets 0700 grafana grafana - -"
    ];

    # No additional systemd configuration needed - using file provider
  };
}
