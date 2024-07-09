{lib, ...}: {
  options = with lib; {
    host = {
      gitSigningKey = mkOption {
        type = types.str;
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
        description = "The git signing key";
      };
      isDarwin = mkOption {
        type = types.bool;
        default = false;
        description = "Is this a Mac?";
      };
      keyboard = mkOption {
        type = with types; nullOr (enum ["moonlander" "voyager"]);
        default = null;
        description = "The keyboard layout";
      };
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
