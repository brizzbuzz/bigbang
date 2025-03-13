{ config, lib, pkgs, ... }:

let
  cfg = config.lgtm.prometheus;
in {
  options.lgtm.prometheus = {
    enable = lib.mkEnableOption "Enable Prometheus";
    port = lib.mkOption {
      type = lib.types.int;
      default = 9090;
      description = "The port for Prometheus";
    };
    retentionTime = lib.mkOption {
      type = lib.types.str;
      default = "14d";
      description = "Data retention time";
    };
    nodeExporter = {
      enable = lib.mkEnableOption "Enable Prometheus Node Exporter";
      port = lib.mkOption {
        type = lib.types.int;
        default = 9100;
        description = "The port for Node Exporter";
      };
      targets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["localhost"];
        description = "List of targets to scrape";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Node exporter configuration
    services.prometheus.exporters.node = lib.mkIf cfg.nodeExporter.enable {
      enable = true;
      enabledCollectors = ["systemd"];
      port = cfg.nodeExporter.port;
    };

    # Full Prometheus server configuration
    services.prometheus = {
      enable = true;
      port = cfg.port;

      # Retention time
      retentionTime = cfg.retentionTime;

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };

      scrapeConfigs = lib.mkIf cfg.nodeExporter.enable [
        {
          job_name = "node";
          static_configs = [
            {
              targets = builtins.map (target: "${target}:${toString cfg.nodeExporter.port}")
                        cfg.nodeExporter.targets;
              labels = {
                group = "production";
              };
            }
          ];
        }
      ];
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [
      cfg.port
    ] ++ lib.optional cfg.nodeExporter.enable cfg.nodeExporter.port;
  };
}
