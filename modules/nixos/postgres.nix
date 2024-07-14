{
  lib,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    authentication = lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };
}
