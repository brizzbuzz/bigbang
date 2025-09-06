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

      immich = {
        enable = mkEnableOption "Enable Immich photo management server";
        port = mkOption {
          type = types.int;
          default = 2283;
          description = "Port for Immich web interface";
        };
      };

      audiobookshelf = {
        enable = mkEnableOption "Enable AudioBookshelf server";
        port = mkOption {
          type = types.int;
          default = 13378;
          description = "Port for AudioBookshelf web interface";
        };
      };

      users = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "The username for this user";
            };
            profile = mkOption {
              type = types.enum ["personal" "work"];
              default = "personal";
              description = "The profile type for this user";
            };
            isPrimary = mkOption {
              type = types.bool;
              default = false;
              description = "Whether this is the primary system user";
            };
            homeManagerEnabled = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to enable Home Manager for this user";
            };
          };
        });
        default = {};
        description = "User configurations";
      };

      profiles = {
        personal = {
          appleIdApps = mkEnableOption "Enable Apple ID dependent apps" // {default = true;};
          entertainmentApps = mkEnableOption "Enable entertainment apps" // {default = true;};
          developmentApps = mkEnableOption "Enable development apps" // {default = true;};
          personalApps = mkEnableOption "Enable personal productivity apps" // {default = true;};
        };
        work = {
          businessApps = mkEnableOption "Enable business apps" // {default = true;};
          restrictedApps = mkEnableOption "Enable restricted work apps" // {default = false;};
          developmentApps = mkEnableOption "Enable development apps" // {default = false;};
        };
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
        enable = lib.mkDefault false;
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

      immich = {
        enable = lib.mkDefault false;
      };

      audiobookshelf = {
        enable = lib.mkDefault false;
      };

      users = lib.mkDefault {
        ryan = {
          name = "ryan";
          profile = "personal";
          isPrimary = true;
          homeManagerEnabled = true;
        };
      };

      profiles = {
        personal = {
          appleIdApps = lib.mkDefault true;
          entertainmentApps = lib.mkDefault true;
          developmentApps = lib.mkDefault true;
          personalApps = lib.mkDefault true;
        };
        work = {
          businessApps = lib.mkDefault true;
          restrictedApps = lib.mkDefault false;
          developmentApps = lib.mkDefault false;
        };
      };
    };
  };
}
