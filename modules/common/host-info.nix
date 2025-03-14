{lib, ...}: {
  options = with lib; {
    ports = {
      attic.server = mkOption {
        type = types.int;
        default = 9001;
        description = "The port to bind to";
      };
      ollama.api = mkOption {
        type = types.int;
        default = 11434;
        description = "The port to bind to";
      };
      open-webui = mkOption {
        type = types.int;
        default = 11435;
        description = "The port to bind to";
      };
    };
    host = {
      caddy = {
        enable = mkEnableOption "Enable Caddy reverse proxy";
        domain = mkOption {
          type = types.str;
          default = "rgbr.ink";
          description = "The primary domain name";
        };
      };

      gitSigningKey = mkOption {
        type = types.str;
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
        description = "The git signing key";
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

      remote.enable = mkEnableOption "Enable Remote Server";

      ai.enable = mkEnableOption "Enable AI Services";

      attic.server = {
        enable = mkEnableOption "Enable Attic Binary Server";
        port = mkOption {
          type = types.int;
          default = config.ports.attic.server;
          description = "The port to bind to";
        };
      };

      jellyfin.server = {
        enable = mkEnableOption "Enable Jellyfin";
      };
    };
  };
  config = {
    host = {
      admin.name = lib.mkDefault "ryan";

      caddy = {
        enable = lib.mkDefault false;
      };

      desktop = {
        enable = lib.mkDefault true;
      };

      gpu.nvidia = {
        enable = lib.mkDefault false;
      };

      remote = {
        enable = lib.mkDefault false;
      };

      ai = {
        enable = lib.mkDefault false;
      };

      attic.server = {
        enable = lib.mkDefault false;
        port = lib.mkDefault 9001;
      };

      jellyfin.server = {
        enable = lib.mkDefault false;
      };
    };
  };
}
