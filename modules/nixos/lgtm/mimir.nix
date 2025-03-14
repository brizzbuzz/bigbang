{ config, lib, ... }:

let
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
      default = "30d";
      description = "Data retention period";
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
          default = "/var/lib/opnix/secrets/minio/mimir-credentials";
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
    # Enable node exporter if requested
    services.prometheus.exporters.node = lib.mkIf cfg.nodeExporter.enable {
      enable = true;
      enabledCollectors = ["systemd"];
      port = cfg.nodeExporter.port;
    };

    # Configure Mimir using the built-in NixOS module
    services.mimir = {
      enable = true;

      configuration = {
        # Basic server configuration
        server = {
          http_listen_port = cfg.port;
        };

        # Common storage configuration
        common = {
          storage = {
            backend = "s3";
            s3 = {
              endpoint = cfg.storage.minio.endpoint;
              bucket_name = cfg.storage.minio.bucketName;
              region = cfg.storage.minio.region;
              insecure = true;
              # Credentials handled via environment variables
            };
          };
        };

        # Configure block storage
        blocks_storage = {
          storage = {
            backend = "s3";
            s3 = {
              endpoint = cfg.storage.minio.endpoint;
              bucket_name = cfg.storage.minio.bucketName;
              region = cfg.storage.minio.region;
              insecure = true;
            };
          };
          bucket_store = {
            sync_dir = "/var/lib/mimir/tsdb-sync";
          };
          tsdb = {
            dir = "/var/lib/mimir/tsdb";
            retention_period = cfg.retentionTime;
          };
        };

        # Storage for other components
        ruler_storage = {
          backend = "s3";
          s3 = {
            endpoint = cfg.storage.minio.endpoint;
            bucket_name = "${cfg.storage.minio.bucketName}-ruler";
            region = cfg.storage.minio.region;
            insecure = true;
          };
        };

        alertmanager_storage = {
          backend = "s3";
          s3 = {
            endpoint = cfg.storage.minio.endpoint;
            bucket_name = "${cfg.storage.minio.bucketName}-alertmanager";
            region = cfg.storage.minio.region;
            insecure = true;
          };
        };

        # Single-instance configuration for homelab use
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

        # Built-in scraping configuration
        prometheus = lib.mkIf cfg.nodeExporter.enable {
          global = {
            scrape_interval = "15s";
            evaluation_interval = "15s";
          };
          scrape_configs = [
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
      };

      # Set environment variables from credentials file
      extraFlags = ["--config.expand-env=true"];
    };

    # Configure environment file for Mimir
    systemd.services.mimir.serviceConfig = {
      EnvironmentFile = cfg.storage.minio.credentialsFile;
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [
      cfg.port
    ] ++ lib.optional cfg.nodeExporter.enable cfg.nodeExporter.port;
  };
}
