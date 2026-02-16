{
  config,
  lib,
  ...
}: {
  config = {
    hardware = lib.mkIf config.host.roles.desktop {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      keyboard = {
        zsa.enable = true;
      };
      ledger.enable = true;
      graphics = {
        enable = true;
      };
    };
  };
}
