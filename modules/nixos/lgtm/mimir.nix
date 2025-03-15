{
  config,
  lib,
  ...
}: let
  cfg = config.lgtm.mimir;
in {
  options.lgtm.mimir = {
    enable = lib.mkEnableOption "Enable Grafana Mimir";

    port = lib.mkOption {
      type = lib.types.int;
      default = 9009;
      description = "The port for Mimir to listen on";
    };

    retentionTime = lib.mkOption {
      type = lib.types.str;
      default = "720h"; # 30 days in hours (using Go duration format)
      description = "Data retention period (in Go duration format, e.g., '720h' for 30 days)";
    };

    storage = {
      minio = {
        endpoint = lib.mkOption {
          type = lib.types.str;
          default = "localhost:9002";
          description = "Minio server endpoint";
        };

        bucketName = lib.mkOption {
          type = lib.types.str;
          default = "mimir";
          description = "Minio bucket name for Mimir";
        };

        region = lib.mkOption {
          type = lib.types.str;
          default = "us-east-1";
          description = "Minio region";
        };

        credentialsFile = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/opnix/secrets/minio/lgtm-credentials";
          description = "Path to the Minio credentials file";
        };
      };
    };

    nodeExporter = {
      enable = lib.mkEnableOption "Enable node exporter support";
      port = lib.mkOption {
        type = lib.types.int;
        default = 9100;
        description = "Node exporter port";
      };
      targets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["localhost"];
        description = "List of node exporter targets";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.mimir = {
      enable = true;

      extraFlags = ["--config.expand-env=true"];

      configuration = {
        target = "all";

        server = {
          http_listen_port = cfg.port;
        };

        # Common storage configuration for S3/Minio
        common = {
          storage = {
            backend = "s3";
            s3 = {
              endpoint = cfg.storage.minio.endpoint;
              bucket_name = cfg.storage.minio.bucketName;
              region = cfg.storage.minio.region;
              insecure = true;
            };
          };
        };

        # Block storage configuration
        blocks_storage = {
          tsdb = {
            dir = "/var/lib/mimir/tsdb";
            retention_period = cfg.retentionTime;
          };
          bucket_store = {
            sync_dir = "/var/lib/mimir/tsdb-sync";
          };
          storage_prefix = "blocks";
        };

        # Ruler storage
        ruler_storage = {
          backend = "s3";
          s3 = {
            endpoint = cfg.storage.minio.endpoint;
            bucket_name = cfg.storage.minio.bucketName;
            region = cfg.storage.minio.region;
            insecure = true;
          };
          storage_prefix = "ruler";
        };

        # Alertmanager storage
        alertmanager_storage = {
          backend = "s3";
          s3 = {
            endpoint = cfg.storage.minio.endpoint;
            bucket_name = cfg.storage.minio.bucketName;
            region = cfg.storage.minio.region;
            insecure = true;
          };
          storage_prefix = "alertmanager";
        };

        compactor = {
          data_dir = "/var/lib/mimir/compactor";
          sharding_ring = {
            kvstore = {
              store = "memberlist";
            };
          };
        };

        distributor = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "memberlist";
          };
        };

        ingester = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "memberlist";
            replication_factor = 1;
          };
        };

        ruler = {
          alertmanager_url = "http://localhost:${toString cfg.port}/alertmanager";
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "memberlist";
          };
        };

        store_gateway = {
          sharding_ring.replication_factor = 1;
        };
      };
    };

    systemd.services.mimir.serviceConfig = {
      EnvironmentFile = cfg.storage.minio.credentialsFile;
      StateDirectory = "mimir"; # Ensure the state directory exists
    };

    networking.firewall.allowedTCPPorts =
      [
        cfg.port
      ]
      ++ lib.optional cfg.nodeExporter.enable cfg.nodeExporter.port;
  };
}
