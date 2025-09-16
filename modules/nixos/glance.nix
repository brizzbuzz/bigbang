{
  config,
  lib,
  ...
}: {
  options = {
    glance.enable = lib.mkEnableOption "Enable Glance Dashboard";

    glance.settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Glance configuration settings";
    };
  };

  config = lib.mkIf config.glance.enable {
    services.glance = {
      enable = true;
      settings = config.glance.settings;
    };
  };
}
