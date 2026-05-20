{
  pkgs,
  config,
  lib,
  ...
}: let
  admin = config.host.admin.name;
  cfg = config.services.postgresql;
  localServiceUsers = lib.unique cfg.serviceUsers;
  remoteServiceUsers = lib.unique cfg.remoteServiceUsers;
  tcpAdminUsers = lib.unique cfg.tcpAdminUsers;
  remoteServiceDatabases = map (user: user.database) remoteServiceUsers;
  passwordManagedUsers = remoteServiceUsers ++ tcpAdminUsers;
  passwordManagedUserCommands =
    lib.concatMapStringsSep "\n" (user: ''
        passwordFile=${lib.escapeShellArg user.passwordFile}

        if [ ! -f "$passwordFile" ]; then
          printf '%s\n' 'Missing PostgreSQL password file for ${user.name}: ${user.passwordFile}' >&2
          exit 1
        fi

        password="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$passwordFile")"
        if [ -z "$password" ]; then
          printf '%s\n' 'PostgreSQL password file for ${user.name} is empty: ${user.passwordFile}' >&2
          exit 1
        fi

      ${cfg.package}/bin/psql -d postgres -v ON_ERROR_STOP=1 \
        --set=role=${lib.escapeShellArg user.name} \
        --set=password="$password" <<'SQL'
      ALTER ROLE :"role" PASSWORD :'password';
      SQL
    '')
    passwordManagedUsers;
in {
  options.services.postgresql = {
    developmentMode = lib.mkEnableOption "development-friendly PostgreSQL tooling";

    serviceDatabases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of databases to create for local system services";
    };

    serviceUsers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Username for the local service";
          };
          database = lib.mkOption {
            type = lib.types.str;
            description = "Database name the local service user should own";
          };
        };
      });
      default = [];
      description = "List of local service users to create with database ownership";
    };

    remoteServiceUsers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Username for the remote service";
          };
          database = lib.mkOption {
            type = lib.types.str;
            description = "Database name the remote service user should own";
          };
          address = lib.mkOption {
            type = lib.types.str;
            example = "192.168.11.200/32";
            description = "Exact CIDR allowed to connect as this remote service user";
          };
          passwordFile = lib.mkOption {
            type = lib.types.str;
            example = "/var/lib/opnix/secrets/authentik-postgres-password";
            description = "Runtime file containing the database password for this remote user";
          };
        };
      });
      default = [];
      description = "List of remote service users allowed to connect over TCP with SCRAM authentication";
    };

    tcpAdminUsers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Admin role allowed to connect over localhost TCP for SSH-tunneled clients";
          };
          passwordFile = lib.mkOption {
            type = lib.types.str;
            example = "/var/lib/opnix/secrets/postgres-ryan-password";
            description = "Runtime file containing the SCRAM password for this tunneled admin user";
          };
        };
      });
      default = [];
      description = "List of admin users allowed over localhost TCP for SSH-tunneled database clients";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      package = pkgs.postgresql_17;
      enableTCPIP = remoteServiceUsers != [];

      ensureDatabases = lib.unique (cfg.serviceDatabases ++ remoteServiceDatabases);

      ensureUsers =
        [
          {
            name = admin;
            ensureClauses = {
              superuser = true;
              createrole = true;
              createdb = true;
              login = true;
              replication = true;
              bypassrls = true;
            };
          }
        ]
        ++ (map (user: {
            name = user.name;
            ensureDBOwnership = true;
            ensureClauses = {
              login = true;
              createdb = false;
            };
          })
          (localServiceUsers ++ remoteServiceUsers));

      authentication = lib.mkForce (let
        localServiceRules = lib.concatMapStringsSep "\n" (user: "local   ${user.database}     ${user.name}                        peer") localServiceUsers;
        remoteServiceRules = lib.concatMapStringsSep "\n" (user: "host    ${user.database}     ${user.name}        ${user.address}    scram-sha-256") remoteServiceUsers;
        tcpAdminRules =
          lib.concatMapStringsSep "\n" (user: ''
            host    all            ${user.name}        127.0.0.1/32    scram-sha-256
            host    all            ${user.name}        ::1/128         scram-sha-256
          '')
          tcpAdminUsers;
      in ''
        # TYPE  DATABASE        USER            ADDRESS         METHOD
        local   all            postgres                         peer
        local   all            ${admin}                        peer

        # Local service users authenticate through matching Unix users.
        ${localServiceRules}

        # Admin TCP access is localhost-only for SSH-tunneled clients.
        ${tcpAdminRules}

        # Remote service users require explicit CIDRs and SCRAM passwords.
        ${remoteServiceRules}
      '');
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (remoteServiceUsers != []) [5432];

    systemd.services.postgresql-service-passwords = lib.mkIf (passwordManagedUsers != []) {
      description = "Apply PostgreSQL service user passwords";
      after = ["opnix-secrets.service" "postgresql.service"];
      requires = ["postgresql.service"];
      wants = ["opnix-secrets.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
      };
      script = ''
        set -euo pipefail

        ${passwordManagedUserCommands}
      '';
    };

    # Install database management tools when in development mode.
    environment.systemPackages = lib.mkIf cfg.developmentMode (with pkgs; [
      postgresql_17
      pgcli
    ]);

    users.groups.postgres = {};
    users.users.${admin}.extraGroups = ["postgres"];
  };
}
