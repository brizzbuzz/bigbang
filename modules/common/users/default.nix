{
  config,
  lib,
  ...
}: let
  cfg = config.host;
in {
  imports = [
    ./accounts.nix
    ./packages.nix
    ./shell.nix
    ./config-files
  ];

  options.host.userManagement = {
    enable = lib.mkEnableOption "Enable pure Nix user management system";
  };

  config = lib.mkIf cfg.userManagement.enable {
    # Enable all user management components
    host = {
      userAccounts.enable = lib.mkDefault true;
      userPackages.enable = lib.mkDefault true;
      userShell.enable = lib.mkDefault true;
      configFiles.enable = lib.mkDefault true;
    };
  };
}
