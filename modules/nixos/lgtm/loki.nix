{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lgtm.loki;
in {
  options.lgtm.loki = {
    enable = lib.mkEnableOption "Enable Grafana Loki";

    port = lib.mkOption {
      type = lib.types.int;
      default = 3100;
      description = "The port for Loki to listen on";
    };

    grpcPort = lib.mkOption {
      type = lib.types.int;
      default = 9096;
      description = "The gRPC port for Loki to listen on";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/loki";
      description = "Directory where Loki stores its data";
    };

    retentionTime = lib.mkOption {
      type = lib.types.str;
      default = "720h"; # 30 days by default
      description = "Log retention period (in Go duration format, e.g., '720h' for 30 days)";
    };

    storage = {
      minio = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to use MinIO for storage";
        };

        endpoint = lib.mkOption {
          type = lib.types.str;
          default = "localhost:9002";
          description = "MinIO server endpoint";
        };

        bucketName = lib.mkOption {
          type = lib.types.str;
          default = "loki";
          description = "MinIO bucket name for Loki";
        };

        region = lib.mkOption {
          type = lib.types.str;
          default = "us-east-1";
          description = "MinIO region";
        };

        credentialsFile = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/opnix/secrets/minio/lgtm-credentials";
          description = "Path to the MinIO credentials file";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;

        server = {
          http_listen_port = cfg.port;
          http_listen_address = "0.0.0.0";
          grpc_listen_port = cfg.grpcPort;
          grpc_listen_address = "0.0.0.0";
        };

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
            final_sleep = "0s";
          };
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
        };

        # Use schema v13 as required for structured metadata
        schema_config = {
          configs = [
            {
              from = "2020-10-24";
              store = "boltdb-shipper";  # We keep this for now but will need to migrate to tsdb eventually
              object_store = if cfg.storage.minio.enable then "s3" else "filesystem";
              schema = "v13"; # Changed from v11 to v13 as required
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "${cfg.dataDir}/index";
            cache_location = "${cfg.dataDir}/cache";
            cache_ttl = "24h";
          };
        } // (if cfg.storage.minio.enable then {
          aws = {
            s3 = "s3://${cfg.storage.minio.region}/${cfg.storage.minio.bucketName}";
            s3forcepathstyle = true;
            endpoint = "http://${cfg.storage.minio.endpoint}";
            insecure = true;
          };
        } else {
          filesystem = {
            directory = "${cfg.dataDir}/chunks";
          };
        });

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          retention_period = cfg.retentionTime;
          # Disable structured metadata since we're not using tsdb index yet
          allow_structured_metadata = false;
        };

        # Add the delete request store as required by validation
        compactor = {
          working_directory = "${cfg.dataDir}/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          # Add this missing configuration
          delete_request_store = "filesystem";
          delete_request_store_key_prefix = "index/";
        };

        table_manager = {
          retention_deletes_enabled = true;
          retention_period = cfg.retentionTime;
        };
      };
    };

    systemd.services = lib.optionalAttrs cfg.storage.minio.enable {
      loki.serviceConfig = {
        EnvironmentFile = cfg.storage.minio.credentialsFile;
      };
    };

    # Create data directory for Loki
    system.activationScripts.createLokiDataDir = {
      deps = [];
      text = ''
        mkdir -p ${cfg.dataDir}
        chmod 700 ${cfg.dataDir}
      '';
    };

    # Open firewall for Loki's ports
    networking.firewall.allowedTCPPorts = [cfg.port cfg.grpcPort];
  };
}
