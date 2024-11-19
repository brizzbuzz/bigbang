{
  pkgs,
  config,
  lib,
  ...
}: let
  admin = config.host.admin.name;
in {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;

    # Enable automatic database initialization
    enableTCPIP = true;

    # Ensure databases exist
    ensureDatabases = [
      "superuser" # Create a database for the superuser
    ];

    # Ensure our superuser exists with proper permissions
    ensureUsers = [
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
    ];

    authentication = ''
      # TYPE  DATABASE        USER            ADDRESS         METHOD
      # Allow postgres and superuser full access
      local   all            postgres                         trust
      local   all            superuser                       trust
      local   all            ${admin}                        peer map=superuser

      # Allow TCP/IP connections with password
      host    all            superuser       127.0.0.1/32    trust
      host    all            superuser       ::1/128         trust
    '';

    # Add identity mapping for admin user to PostgreSQL role
    identMap = ''
      superuser ${admin} superuser
      superuser /^(.*)$ \1
    '';
  };

  # Add postgres group to system groups
  users.groups.postgres = {};

  # Ensure admin user is in postgres group
  users.users.${admin}.extraGroups = ["postgres"];
}
