{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.host.minio.server.enable {
    services.minio = {
      enable = true;
      dataDir = ["/var/lib/minio"];
      region = "us-east-1";
      rootCredentialsFile = "/var/lib/opnix/secrets/minio/root-credentials";
      listenAddress = ":${toString config.host.minio.server.port}";
      consoleAddress = ":${toString config.host.minio.server.consolePort}";
    };

    systemd.services.minio.serviceConfig = {
      StateDirectory = "minio";
    };

    # Optional: Open firewall ports if needed
    networking.firewall.allowedTCPPorts = [
      config.host.minio.server.port
      config.host.minio.server.consolePort
    ];
  };
}
