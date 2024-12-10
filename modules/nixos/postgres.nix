{
  pkgs,
  config,
  ...
}: let
  admin = config.host.admin.name;
in {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;

    ensureDatabases = [
      "superuser"
    ];

    ensureUsers = [
      {
        name = "superuser";
        ensureDBOwnership = true;
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
        name = "roland";
        ensureClauses = {
          login = true;
          createdb = false;
          createrole = false;
        };
      }
    ];

    authentication = ''
      # TYPE  DATABASE        USER            ADDRESS         METHOD
      local   all            postgres                         trust
      local   all            superuser                       trust
      local   all            ${admin}                        peer map=superuser
      # Roland read-only access with password
      local   all            roland                          scram-sha-256
      host    all            roland          127.0.0.1/32    scram-sha-256
      host    all            roland          ::1/128         scram-sha-256
      # Superuser TCP access
      host    all            superuser       127.0.0.1/32    trust
      host    all            superuser       ::1/128         trust
    '';

    # Setup read-only permissions for roland
    initialScript = pkgs.writeText "postgres-init.sql" ''
      REVOKE ALL ON ALL TABLES IN SCHEMA public FROM roland;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO roland;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO roland;
    '';

    identMap = ''
      superuser ${admin} superuser
      superuser /^(.*)$ \1
    '';
  };

  # Service to set up roland's password after both PostgreSQL and OPNix are ready
  systemd.services.setup-roland-password = {
    description = "Set up PostgreSQL password for roland";
    after = ["postgresql.service" "onepassword-secrets.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = ''
      # Ensure password file exists
      while [ ! -f /var/lib/opnix/secrets/postgresql/roland-password ]; do
        sleep 1
      done

      # Set password for roland
      psql -d postgres -c "ALTER USER roland WITH PASSWORD '$(cat /var/lib/opnix/secrets/postgresql/roland-password)';"
    '';
  };

  users.groups.postgres = {};
  users.users.${admin}.extraGroups = ["postgres"];
}
