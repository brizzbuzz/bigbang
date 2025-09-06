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
      mediaLocation = "/srv/immich";
    };

    # Create media storage directory
    systemd.tmpfiles.rules = [
      "d /srv/immich 0750 immich immich -"
      "d /srv/immich/upload 0750 immich immich -"
      "d /srv/immich/profile 0750 immich immich -"
      "d /srv/immich/thumbs 0750 immich immich -"
      "d /srv/immich/encoded-video 0750 immich immich -"
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
