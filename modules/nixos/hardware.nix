{
  config,
  lib,
  ...
}: {
  config = {
    hardware = lib.mkIf config.host.desktop.enable {
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
