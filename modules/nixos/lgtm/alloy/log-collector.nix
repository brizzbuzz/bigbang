{
  config,
  lib,
  ...
}: let
  cfg = config.lgtm.alloy.logCollector;
in {
  options.lgtm.alloy.logCollector = {
    enable = lib.mkEnableOption "Enable log collection with Alloy";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:3100/loki/api/v1/push";
      description = "Loki push API endpoint";
    };

    logPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["/var/log/*.log"];
      description = "Paths to log files to collect (supports glob patterns)";
      example = lib.literalExpression ''
        [
          "/var/log/*.log"
          "/var/log/nginx/*.log"
        ]
      '';
    };

    excludePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Regex patterns for log lines to exclude";
      example = lib.literalExpression ''
        [
          ".*Connection closed by authenticating user root.*"
          ".*DEBUG.*"
        ]
      '';
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Hostname label to add to log entries";
    };

    additionalLabels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional labels to add to log entries";
      example = lib.literalExpression ''
        {
          environment = "production";
          role = "webserver";
        }
      '';
    };

    syncPeriod = lib.mkOption {
      type = lib.types.str;
      default = "10s";
      description = "How often to check for new log files";
    };
  };

  config = lib.mkIf (config.lgtm.alloy.enable && cfg.enable) {
    # Configure alloy for log collection - avoid directly enabling alloy here to prevent recursion
    lgtm.alloy.configs = let
      # Create drop stages for each exclude pattern
      dropStages = lib.concatMapStrings (pattern: ''
        stage.drop {
          expression = "${pattern}"
          source = ""
          drop_counter_reason = "filtered"
        }
      '') cfg.excludePatterns;

      # Create a formatted list of path targets
      pathTargetsStr = lib.concatMapStringsSep ", " (path: ''{"__path__" = "${path}"}'') cfg.logPaths;

      # Convert additional labels to a string representation
      labels = cfg.additionalLabels // { "hostname" = cfg.hostname; };

      # This explicitly adds comma after each entry INCLUDING the last one
      labelStr =
        lib.concatStringsSep "\n"
        (map (entry: "${entry},")
          (lib.mapAttrsToList (k: v: ''      "${k}" = "${v}"'') labels));
    in {
      "log_collection.alloy" = ''
        // Log collection configuration
        local.file_match "local_logs" {
          path_targets = [${pathTargetsStr}]
          sync_period = "${cfg.syncPeriod}"
        }

        loki.source.file "log_scraper" {
          targets = local.file_match.local_logs.targets
          forward_to = [loki.process.log_processor.receiver]
          tail_from_end = true
        }

        loki.process "log_processor" {
          ${dropStages}

          // Add static labels to all logs
          stage.static_labels {
            values = {
${labelStr}
            }
          }

          forward_to = [loki.write.remote_loki.receiver]
        }

        loki.write "remote_loki" {
          endpoint {
            url = "${cfg.lokiUrl}"

            // Uncomment and set these if your Loki requires authentication
            // basic_auth {
            //   username = "tenant1"
            //   password = "tenant1"
            // }
          }
        }
      '';
    };
  };
}
