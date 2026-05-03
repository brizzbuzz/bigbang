{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.netbird-combined;

  authSecretPath = "/var/lib/opnix/secrets/netbird-auth-secret";
  storeEncryptionKeyPath = "/var/lib/opnix/secrets/netbird-store-encryption-key";
  configPath = "/run/netbird/config.yaml";
  listenAddress = "${cfg.listenAddress}:${toString cfg.port}";
  exposedAddress = "https://${cfg.domain}:443";
  authIssuer = "https://${cfg.domain}/oauth2";
  stunPortsYaml =
    if cfg.stun.enable
    then "stunPorts:\n    - ${toString cfg.stun.port}"
    else "stunPorts: []";
in {
  options.services.netbird-combined = {
    enable = lib.mkEnableOption "combined NetBird self-hosted server";

    package = lib.mkPackageOption pkgs "netbird-server" {};

    domain = lib.mkOption {
      type = lib.types.str;
      default = "netbird.rgbr.ink";
      description = "Public domain for the NetBird management, signal, and relay endpoint.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for the combined NetBird HTTP listener.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for the combined NetBird HTTP listener.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/netbird";
      description = "State directory for NetBird data and embedded identity storage.";
    };

    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port for NetBird metrics.";
    };

    healthcheckAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:9000";
      description = "Address for the NetBird healthcheck endpoint.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["debug" "info" "warn" "error"];
      default = "info";
      description = "NetBird server log level.";
    };

    disableAnonymousMetrics = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable NetBird anonymous metrics collection.";
    };

    disableGeoliteUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable NetBird GeoLite database updates.";
    };

    stun = {
      enable = lib.mkEnableOption "the local NetBird STUN listener" // {default = true;};

      port = lib.mkOption {
        type = lib.types.port;
        default = 3478;
        description = "UDP port for the local NetBird STUN listener.";
      };
    };

    authSecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the NetBird relay authentication secret.";
    };

    storeEncryptionKeySecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the NetBird datastore encryption key.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authSecretRef != null;
        message = "services.netbird-combined.authSecretRef must be set.";
      }
      {
        assertion = cfg.storeEncryptionKeySecretRef != null;
        message = "services.netbird-combined.storeEncryptionKeySecretRef must be set.";
      }
    ];

    users.groups.netbird = {};
    users.users.netbird = {
      isSystemUser = true;
      group = "netbird";
    };

    services.onepassword-secrets.secrets = {
      netbirdAuthSecret = {
        reference = cfg.authSecretRef;
        path = authSecretPath;
        owner = "netbird";
        group = "netbird";
        mode = "0400";
      };

      netbirdStoreEncryptionKey = {
        reference = cfg.storeEncryptionKeySecretRef;
        path = storeEncryptionKeyPath;
        owner = "netbird";
        group = "netbird";
        mode = "0400";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.dataDir} 0750 netbird netbird -"
    ];

    networking.firewall.allowedUDPPorts = lib.optional cfg.stun.enable cfg.stun.port;

    systemd.services.netbird-combined = {
      description = "Combined NetBird self-hosted server";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      requires = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      preStart = ''
        set -euo pipefail

        auth_secret_file=${lib.escapeShellArg authSecretPath}
        store_encryption_key_file=${lib.escapeShellArg storeEncryptionKeyPath}
        config_path=${lib.escapeShellArg configPath}

        if [ ! -f "$auth_secret_file" ]; then
          printf '%s\n' "Missing NetBird auth secret at $auth_secret_file" >&2
          exit 1
        fi

        if [ ! -f "$store_encryption_key_file" ]; then
          printf '%s\n' "Missing NetBird store encryption key at $store_encryption_key_file" >&2
          exit 1
        fi

        auth_secret="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$auth_secret_file")"
        store_encryption_key="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$store_encryption_key_file")"

        ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$config_path"
        ${pkgs.bash}/bin/bash -c 'cat > "$1"' -- "$config_path" <<EOF
        server:
          listenAddress: ${listenAddress}
          exposedAddress: ${exposedAddress}
          metricsPort: ${toString cfg.metricsPort}
          healthcheckAddress: ${cfg.healthcheckAddress}
          logLevel: ${cfg.logLevel}
          logFile: console
          dataDir: ${toString cfg.dataDir}
          authSecret: $auth_secret
          ${stunPortsYaml}
          disableAnonymousMetrics: ${lib.boolToString cfg.disableAnonymousMetrics}
          disableGeoliteUpdate: ${lib.boolToString cfg.disableGeoliteUpdate}
          store:
            engine: sqlite
            encryptionKey: $store_encryption_key
          auth:
            issuer: ${authIssuer}
            storage:
              type: sqlite3
            dashboardRedirectURIs:
              - https://${cfg.domain}
            cliRedirectURIs:
              - http://localhost:53000
        EOF
      '';
      serviceConfig = {
        Type = "simple";
        User = "netbird";
        Group = "netbird";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "netbird";
        RuntimeDirectory = "netbird";
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          cfg.dataDir
          "/run/netbird"
        ];
      };
    };
  };
}
