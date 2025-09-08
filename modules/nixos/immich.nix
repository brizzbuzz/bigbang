{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.immich.enable {
    services.immich = {
      enable = true;
      port = config.host.immich.port;
      host = "0.0.0.0";
      database = {
        host = "/run/postgresql";
        name = "immich";
        user = "immich";
        createDB = true;
        enableVectors = false;
      };
      mediaLocation = "/data/immich";
      # Disable machine learning to avoid resource-intensive video processing
      machine-learning = {
        enable = false;
      };
      # Configure settings to optimize for large file uploads and disable ML features
      settings = {
        job = {
          smartSearch.enabled = false;
          faceDetection.enabled = false;
          facialRecognition.enabled = false;
          # Keep thumbnail generation enabled for videos
          thumbnailGeneration.enabled = true;
          videoConversion.enabled = true;
        };
        # Disable new version checking for privacy
        newVersionCheck.enabled = false;
      };
    };

    # Create media storage directories on the dedicated media drive
    systemd.tmpfiles.rules = [
      "d /data/immich 0750 immich immich -"
      "d /data/immich/upload 0750 immich immich -"
      "d /data/immich/profile 0750 immich immich -"
      "d /data/immich/thumbs 0750 immich immich -"
      "d /data/immich/encoded-video 0750 immich immich -"
      "d /data/immich/library 0750 immich immich -"
      "d /data/immich/backups 0750 immich immich -"
    ];

    # Add Immich database and user to PostgreSQL configuration
    services.postgresql.serviceDatabases = ["immich"];
    services.postgresql.serviceUsers = [
      {
        name = "immich";
        database = "immich";
      }
    ];

    # Open firewall port for Immich
    networking.firewall.allowedTCPPorts = [config.host.immich.port];
  };
}
