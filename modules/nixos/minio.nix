{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.host.minio.server.enable {
    services.minio = {
      enable = true;
      # Configure the data directory
      dataDir = ["/var/lib/minio"];
      # Configure the region (optional)
      region = "us-east-1";
      # Configure access credentials
      rootCredentialsFile = "/etc/minio/credentials";
      # Configure the API listen address - convert port to string
      listenAddress = ":${toString config.host.minio.server.port}";
      # Configure the Console listen address - convert port to string
      consoleAddress = ":${toString config.host.minio.server.consolePort}";
    };

    # Create necessary directories and set permissions
    systemd.services.minio.serviceConfig = {
      StateDirectory = "minio";
    };

    # Create credentials file
    system.activationScripts.minio-credentials = {
      text = ''
        if [ ! -f /etc/minio/credentials ]; then
          mkdir -p /etc/minio
          echo "MINIO_ROOT_USER=admin" > /etc/minio/credentials
          echo "MINIO_ROOT_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)" >> /etc/minio/credentials
          chmod 600 /etc/minio/credentials
        fi
      '';
    };

    # Optional: Open firewall ports if needed
    networking.firewall.allowedTCPPorts = [
      config.host.minio.server.port
      config.host.minio.server.consolePort
    ];
  };
}
