{
  pkgs,
  config,
  lib,
  ...
}: let
  admin = config.host.admin.name;
  cfg = config.services.postgresql;
in {
  options.services.postgresql = {
    developmentMode = lib.mkEnableOption "development-friendly PostgreSQL configuration";

    serviceDatabases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of databases to create for system services";
    };

    serviceUsers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Username for the service";
          };
          database = lib.mkOption {
            type = lib.types.str;
            description = "Database name the user should own";
          };
        };
      });
      default = [];
      description = "List of service users to create with database ownership";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      package = pkgs.postgresql_17;
      enableTCPIP = true;

      # Ensure databases exist
      ensureDatabases =
        [
          "superuser" # Create a database for the superuser
        ]
        ++ cfg.serviceDatabases;

      # Ensure our superuser exists with proper permissions
      ensureUsers =
        [
          {
            name = "superuser";
            ensureDBOwnership = true; # Give ownership of the superuser database
            ensureClauses = {
              superuser = true;
              createrole = true;
              createdb = true;
              login = true;
              replication = true;
              bypassrls = true;
            };
          }
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
          cfg.serviceUsers);

      authentication = pkgs.lib.mkOverride 10 (
        ''
          # TYPE  DATABASE        USER            ADDRESS         METHOD
          # Allow postgres and superuser full access
          local   all            postgres                         trust
          local   all            superuser                       trust
          local   all            ${admin}                        trust

          # Allow TCP/IP connections with trust
          host    all            postgres        127.0.0.1/32    trust
          host    all            postgres        ::1/128         trust
          host    all            superuser       127.0.0.1/32    trust
          host    all            superuser       ::1/128         trust
          host    all            ${admin}        127.0.0.1/32    trust
          host    all            ${admin}        ::1/128         trust
        ''
        + lib.optionalString cfg.developmentMode ''

          # Development mode: Allow TCP/IP connections for all users from local networks
          host    all            all             192.168.0.0/16  trust
          host    all            all             10.0.0.0/8      trust
          host    all            all             172.16.0.0/12   trust

          # Service users specific access
          ${lib.concatMapStringsSep "\n" (user: "host    ${user.database}     ${user.name}        127.0.0.1/32    trust") cfg.serviceUsers}
          ${lib.concatMapStringsSep "\n" (user: "host    ${user.database}     ${user.name}        ::1/128         trust") cfg.serviceUsers}
        ''
      );

      # Add identity mapping for admin user to PostgreSQL role
      identMap = pkgs.lib.mkOverride 10 ''
        # superuser_map allows root and postgres system users to login as postgres DB user
        superuser_map      root      postgres
        superuser_map      postgres  postgres
        superuser_map      ${admin}  superuser
        # Let other names login as themselves (except admin which is handled above)
        superuser_map      /^(?!${admin}$)(.*)$   \1
      '';
    };

    # Open PostgreSQL port for development connections when in development mode
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.developmentMode [5432];

    # Install database management tools when in development mode
    environment.systemPackages = lib.mkIf cfg.developmentMode (with pkgs; [
      postgresql_17
      pgcli
    ]);

    # Add postgres group to system groups
    users.groups.postgres = {};

    # Ensure admin user is in postgres group
    users.users.${admin}.extraGroups = ["postgres"];
  };
}
