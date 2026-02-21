{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clickhouse;
  secretPath = "/var/lib/opnix/secrets/clickhouse-password-sha256";
  usersFile = "/etc/clickhouse-server/users.d/100-opnix-admin.yaml";
  defaultDisableFile = "/etc/clickhouse-server/users.d/200-opnix-disable-default.xml";
in {
  options.services.clickhouse = {
    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "admin";
      description = "ClickHouse admin username to configure.";
    };

    passwordSha256SecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for ClickHouse password_sha256_hex.";
    };

    dataPath = lib.mkOption {
      type = lib.types.str;
      default = "/data/clickhouse";
      description = "ClickHouse data directory.";
    };

    listenHost = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Bind address for ClickHouse TCP/HTTP listeners.";
    };

    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 8123;
      description = "HTTP port for ClickHouse.";
    };

    tcpPort = lib.mkOption {
      type = lib.types.int;
      default = 9000;
      description = "Native TCP port for ClickHouse.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for ClickHouse.";
    };

    disableDefaultUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable the default ClickHouse user.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.passwordSha256SecretRef != null;
        message = "services.clickhouse.passwordSha256SecretRef must be set.";
      }
    ];

    services.clickhouse = {
      package = lib.mkDefault pkgs.clickhouse-lts;
      serverConfig.listen_host = lib.mkDefault cfg.listenHost;
      serverConfig.http_port = lib.mkDefault cfg.httpPort;
      serverConfig.tcp_port = lib.mkDefault cfg.tcpPort;
      serverConfig.path = lib.mkDefault cfg.dataPath;
    };

    services.onepassword-secrets.secrets.clickhousePasswordSha256 = {
      reference = cfg.passwordSha256SecretRef;
      path = secretPath;
      owner = "root";
      group = "root";
      mode = "0600";
    };

    services.onepassword-secrets.systemdIntegration.services = lib.mkAfter [
      "clickhouse"
      "clickhouse-users-credentials"
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataPath} 0750 clickhouse clickhouse -"
    ];

    systemd.services.clickhouse-users-credentials = {
      description = "Generate ClickHouse users config from Opnix secrets";
      after = ["opnix-secrets.service"];
      requires = ["opnix-secrets.service"];
      wantedBy = ["clickhouse.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail

        secret_file="${secretPath}"
        users_file="${usersFile}"

        if [ ! -f "$secret_file" ]; then
          exit 1
        fi

        ${pkgs.coreutils}/bin/install -d -m 0750 -o root -g clickhouse /etc/clickhouse-server/users.d

        password_sha256_hex="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$secret_file" | ${pkgs.coreutils}/bin/cut -d ' ' -f1)"

      ${pkgs.coreutils}/bin/printf '%s\n' \
        "profiles:" \
        "  default: {}" \
        "" \
        "users:" \
        "  ${cfg.adminUser}:" \
        "    profile: default" \
        "    password_sha256_hex: \"$password_sha256_hex\"" \
        > "$users_file"

        if ${lib.boolToString cfg.disableDefaultUser}; then
          ${pkgs.coreutils}/bin/cat > "${defaultDisableFile}" <<'EOF'
<clickhouse>
  <users>
    <default remove="true" />
  </users>
</clickhouse>
EOF
          ${pkgs.coreutils}/bin/chown root:clickhouse "${defaultDisableFile}"
          ${pkgs.coreutils}/bin/chmod 0640 "${defaultDisableFile}"
        else
          ${pkgs.coreutils}/bin/rm -f "${defaultDisableFile}"
        fi

        ${pkgs.coreutils}/bin/chown root:clickhouse "$users_file"
        ${pkgs.coreutils}/bin/chmod 0640 "$users_file"
      '';
    };

    systemd.services.clickhouse = {
      after = [
        "opnix-secrets.service"
        "clickhouse-users-credentials.service"
      ];
      requires = [
        "opnix-secrets.service"
        "clickhouse-users-credentials.service"
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.httpPort
      cfg.tcpPort
    ];
  };
}
