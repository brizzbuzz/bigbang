{
  config,
  lib,
  ...
}: let
  cfg = config.services.minio-server;
in {
  options.services.minio-server = {
    enable = lib.mkEnableOption "Enable Minio Server";

    port = lib.mkOption {
      type = lib.types.int;
      default = 9002;
      description = "Port for the Minio server API";
    };

    consolePort = lib.mkOption {
      type = lib.types.int;
      default = 9003;
      description = "Port for the Minio web console";
    };

    dataDir = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["/var/lib/minio"];
      description = "Data directories for Minio storage";
    };

    region = lib.mkOption {
      type = lib.types.str;
      default = "us-east-1";
      description = "Region for the Minio server";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opnix/secrets/minio/root-credentials";
      description = "Path to the Minio root credentials file";
    };
  };

  config = lib.mkIf cfg.enable {
    services.minio = {
      enable = true;
      dataDir = cfg.dataDir;
      region = cfg.region;
      rootCredentialsFile = cfg.credentialsFile;
      listenAddress = ":${toString cfg.port}";
      consoleAddress = ":${toString cfg.consolePort}";
    };

    systemd.services.minio.serviceConfig = {
      StateDirectory = "minio";
    };

    # Open firewall ports if needed
    networking.firewall.allowedTCPPorts = [
      cfg.port
      cfg.consolePort
    ];
  };
}
