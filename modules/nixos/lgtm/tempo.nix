{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lgtm.tempo;
in {
  options.lgtm.tempo = {
    enable = lib.mkEnableOption "Enable Grafana Tempo";

    port = lib.mkOption {
      type = lib.types.int;
      default = 3200;
      description = "The HTTP port for Tempo to listen on";
    };

    grpcPort = lib.mkOption {
      type = lib.types.int;
      default = 9095;
      description = "The gRPC port for Tempo to listen on";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tempo";
      description = "Directory where Tempo stores its data";
    };

    retentionTime = lib.mkOption {
      type = lib.types.str;
      default = "336h"; # 14 days by default
      description = "Trace retention period (in Go duration format, e.g., '336h' for 14 days)";
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
          default = "tempo";
          description = "MinIO bucket name for Tempo";
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
    services.tempo = {
      enable = true;

      settings = {
        server = {
          http_listen_port = cfg.port;
          grpc_listen_port = cfg.grpcPort;
        };

        distributor = {
          receivers = {
            jaeger = {
              protocols = {
                thrift_http = {
                  endpoint = "0.0.0.0:14268";
                };
                grpc = {
                  endpoint = "0.0.0.0:14250";
                };
                thrift_binary = {
                  endpoint = "0.0.0.0:6832";
                };
                thrift_compact = {
                  endpoint = "0.0.0.0:6831";
                };
              };
            };
            otlp = {
              protocols = {
                grpc = {
                  endpoint = "0.0.0.0:4317";
                };
                http = {
                  endpoint = "0.0.0.0:4318";
                };
              };
            };
            zipkin = {
              endpoint = "0.0.0.0:9411";
            };
          };
        };

        ingester = {
          max_block_duration = "30m";
          max_block_bytes = 512000000; # ~512 MB
          trace_idle_period = "10s";
        };

        compactor = {
          compaction = {
            compaction_window = "1h";
            max_block_bytes = 100000000000; # ~100GB
            block_retention = cfg.retentionTime;
            compacted_block_retention = "1h";
          };
        };

        storage = {
          trace = {
            backend = if cfg.storage.minio.enable then "s3" else "local";
            wal = {
              path = "${cfg.dataDir}/wal";
            };

            # S3/MinIO configuration
            s3 = lib.mkIf cfg.storage.minio.enable {
              bucket = cfg.storage.minio.bucketName;
              endpoint = cfg.storage.minio.endpoint;
              region = cfg.storage.minio.region;
              insecure = true;
              forcepathstyle = true;
            };

            # Local storage configuration
            local = lib.mkIf (!cfg.storage.minio.enable) {
              path = "${cfg.dataDir}/blocks";
            };
          };
        };

        querier = {
          search = {
            query_timeout = "30s";
          };
          trace_by_id = {
            query_timeout = "10s";
          };
        };
      };
    };

    # Add environment variables for S3/MinIO credentials
    systemd.services = lib.optionalAttrs cfg.storage.minio.enable {
      tempo.serviceConfig = {
        EnvironmentFile = cfg.storage.minio.credentialsFile;
      };
    };

    # Create data directory for Tempo
    system.activationScripts.createTempoDataDir = {
      deps = [];
      text = ''
        mkdir -p ${cfg.dataDir}/{wal,blocks}
        chmod 700 ${cfg.dataDir}
        chmod 700 ${cfg.dataDir}/wal
        chmod 700 ${cfg.dataDir}/blocks
      '';
    };

    # Open firewall ports for Tempo
    networking.firewall.allowedTCPPorts = [
      # Main Tempo ports
      cfg.port
      cfg.grpcPort
      # Receivers ports
      14268 # Jaeger thrift HTTP
      14250 # Jaeger gRPC
      6831  # Jaeger thrift compact
      6832  # Jaeger thrift binary
      4317  # OTLP gRPC
      4318  # OTLP HTTP
      9411  # Zipkin
    ];
  };
}
