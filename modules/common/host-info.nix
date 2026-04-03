{lib, ...}: {
  options = with lib; {
    ports = {
    };
    host = {
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

      roles = {
        desktop = mkEnableOption "Enable desktop role";
        remote = mkEnableOption "Enable remote server role";
      };

      hardware = {
        gpu = {
          nvidia.enable = mkEnableOption "Enable Nvidia GPU Drivers";
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
              type = types.enum ["personal" "company"];
              default = "personal";
              description = "The profile type for this user";
            };
            isPrimary = mkOption {
              type = types.bool;
              default = false;
              description = "Whether this is the primary system user";
            };
            git = {
              name = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override git user.name (defaults to profile setting)";
              };
              email = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override git user.email (defaults to profile setting)";
              };
              signingKey = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override git signing key (defaults to profile setting)";
              };
            };
            ghostty = {
              theme = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override Ghostty theme (defaults to profile setting)";
              };
              font-family = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override Ghostty font family (defaults to profile setting)";
              };
              font-size = mkOption {
                type = types.nullOr types.int;
                default = null;
                description = "Override Ghostty font size (defaults to profile setting)";
              };
              background-opacity = mkOption {
                type = types.nullOr types.float;
                default = null;
                description = "Override Ghostty background opacity 0.0-1.0 (defaults to profile setting)";
              };
              cursor-style = mkOption {
                type = types.nullOr (types.enum ["block" "bar" "underline" "block_hollow"]);
                default = null;
                description = "Override Ghostty cursor style (defaults to profile setting)";
              };
              extraConfig = mkOption {
                type = types.lines;
                default = "";
                description = "Additional raw Ghostty configuration";
              };
            };
            helix = {
              theme = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Override Helix theme (defaults to profile setting)";
              };
            };
          };
        });
        default = {};
        description = "User configurations";
      };

      profiles = {
        personal = {
          entertainmentApps = mkEnableOption "Enable entertainment apps" // {default = true;};
          developmentApps = mkEnableOption "Enable development apps" // {default = true;};
          personalApps = mkEnableOption "Enable personal productivity apps" // {default = true;};
        };
        company = {
          businessApps = mkEnableOption "Enable business apps" // {default = true;};
          restrictedApps = mkEnableOption "Enable restricted company apps" // {default = false;};
          developmentApps = mkEnableOption "Enable development apps" // {default = false;};
        };
      };
    };
  };
  config = {
    host = {
      admin.name = lib.mkDefault "ryan";

      roles = {
        desktop = lib.mkDefault false;
        remote = lib.mkDefault false;
      };

      hardware.gpu.nvidia = {
        enable = lib.mkDefault false;
      };
      users = lib.mkDefault {
        ryan = {
          name = "ryan";
          profile = "personal";
          isPrimary = true;
        };
      };

      profiles = {
        personal = {
          entertainmentApps = lib.mkDefault true;
          developmentApps = lib.mkDefault true;
          personalApps = lib.mkDefault true;
        };
        company = {
          businessApps = lib.mkDefault true;
          restrictedApps = lib.mkDefault false;
          developmentApps = lib.mkDefault false;
        };
      };
    };
  };
}
