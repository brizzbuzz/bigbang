{
  config,
  lib,
  ...
}: {
  options = with lib; {
    host = {
      name = mkOption {
        type = types.str;
        default = "nixos";
        description = "The hostname of the machine";
      };
      admin = {
        name = mkOption {
          type = types.str;
          default = "admin";
          description = "The name of the admin user";
        };
      };
      desktop = {
        enable = mkEnableOption "Enable Desktop Environment";
      };
      gpu = {
        nvidia.enable = mkEnableOption "Enable Nvidia GPU Drivers";
      };
      remote = {
        enable = mkEnableOption "Enable Remote Server";
      };
    };
  };
  config = {
    host = {
      admin.name = lib.mkDefault "ryan";

      desktop = {
        enable = lib.mkDefault true;
      };

      gpu.nvidia = {
        enable = lib.mkDefault false;
      };

      remote = {
        enable = lib.mkDefault false;
      };
    };
  };
}
