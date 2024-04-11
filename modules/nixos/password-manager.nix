{
  config,
  lib,
  ...
}: {
  options = {
    password-manager = {
      enable = lib.mkEnableOption "Enable password manager";
      gui = {
        enable = lib.mkEnableOption "Enable password manager GUI";
        polkitPolicyOwners = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of users who should be allowed to run the password manager GUI with elevated privileges";
        };
      };
    };
  };

  config = lib.mkIf config.password-manager.enable {
    programs._1password.enable = true;
    programs._1password-gui.enable = config.password-manager.gui.enable;
    programs._1password-gui.polkitPolicyOwners = config.password-manager.gui.polkitPolicyOwners;
  };
}
