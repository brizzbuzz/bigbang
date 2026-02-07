{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  configFiles = cfg.configFiles;
  isDarwin = pkgs.stdenv.isDarwin;

  # Import config modules
  gitModule = import ./configs/git.nix {inherit config lib pkgs;};
  sshModule = import ./configs/ssh.nix {inherit config lib pkgs;};
  onePasswordModule = import ./configs/onepassword.nix {inherit config lib pkgs;};
  starshipModule = import ./configs/starship.nix {inherit config lib pkgs;};
  zellijModule = import ./configs/zellij.nix {inherit config lib pkgs;};
  nushellModule = import ./configs/nushell.nix {inherit config lib pkgs;};
  opencodeModule = import ./configs/opencode.nix {inherit config lib pkgs;};
  ghosttyModule = import ./configs/ghostty.nix {inherit config lib pkgs;};
  helixModule = import ./configs/helix.nix {inherit config lib pkgs;};
  direnvModule = import ./configs/direnv.nix {inherit config lib pkgs;};

  # Generate activation script for a single user
  mkUserConfigScript = userName: let
    user = cfg.users.${userName};
    homeDir =
      if isDarwin
      then "/Users/${userName}"
      else "/home/${userName}";
    userGroup =
      if isDarwin
      then "staff"
      else userName;
  in ''
    # === Config files for ${userName} ===
    echo "Deploying config files for ${userName}..."

    # Create config directories
    mkdir -p "${homeDir}/.config/1Password/ssh"
    mkdir -p "${homeDir}/.config/starship"
    mkdir -p "${homeDir}/.config/zellij"
    mkdir -p "${homeDir}/.config/opencode"
    mkdir -p "${homeDir}/.config/ghostty/themes"
    mkdir -p "${homeDir}/.config/helix"
    mkdir -p "${homeDir}/.config/direnv"
    mkdir -p "${homeDir}/.ssh"

    ${onePasswordModule.mkOnePasswordScript {
      inherit user homeDir;
      enabled = configFiles.onePassword.enable;
    }}

    ${sshModule.mkSshScript {
      inherit homeDir;
      enabled = configFiles.ssh.enable;
    }}

    ${gitModule.mkGitScript {
      inherit user homeDir;
      enabled = configFiles.git.enable;
    }}

    ${starshipModule.mkStarshipScript {
      inherit homeDir;
      enabled = configFiles.starship.enable;
    }}

    ${zellijModule.mkZellijScript {
      inherit homeDir;
      enabled = configFiles.zellij.enable;
    }}

    ${nushellModule.mkNushellScript {
      inherit userName homeDir userGroup;
      enabled = configFiles.nushell.enable;
    }}

    ${opencodeModule.mkOpencodeScript {
      inherit homeDir;
      enabled = configFiles.opencode.enable;
    }}

    ${ghosttyModule.mkGhosttyScript {
      inherit user homeDir;
      enabled = configFiles.ghostty.enable;
    }}

    ${helixModule.mkHelixScript {
      inherit user homeDir;
      enabled = configFiles.helix.enable;
    }}

    ${direnvModule.mkDirenvScript {
      inherit homeDir;
      enabled = configFiles.direnv.enable;
    }}

    # Set ownership (ignore errors if user doesn't exist yet)
    chown -R "${userName}:${userGroup}" "${homeDir}/.config" "${homeDir}/.ssh" 2>/dev/null || true
    ${lib.optionalString configFiles.git.enable ''
      chown "${userName}:${userGroup}" "${homeDir}/.gitconfig" 2>/dev/null || true
    ''}
  '';
in {
  options.host.configFiles = {
    enable = lib.mkEnableOption "user configuration file management";

    starship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy starship prompt configuration";
      };
    };

    zellij = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy zellij terminal multiplexer configuration";
      };
    };

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy SSH client configuration";
      };
    };

    git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy git configuration";
      };
    };

    onePassword = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy 1Password SSH agent configuration";
      };
    };

    nushell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy nushell configuration";
      };
    };

    opencode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy opencode AI assistant configuration";
      };
    };

    ghostty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy ghostty terminal configuration";
      };
    };

    helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy helix editor configuration";
      };
    };

    direnv = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Deploy direnv configuration";
      };
    };
  };

  config = lib.mkIf configFiles.enable {
    # Deploy configuration files via activation script
    # Use postActivation for nix-darwin compatibility (extraActivation runs too early)
    system.activationScripts.postActivation.text = lib.mkAfter ''
      # === User Config Files Deployment ===
      ${lib.concatMapStringsSep "\n" mkUserConfigScript (lib.attrNames cfg.users)}
    '';

    # Git packages (moved from git.nix)
    environment.systemPackages = with pkgs;
      [
        git
        gh
      ]
      ++ lib.optionals configFiles.opencode.enable [
        playwright-mcp
        uv
        nodejs_22 # Provides npx for browser MCP
      ]
      ++ lib.optionals configFiles.ghostty.enable [
        (
          if pkgs.stdenv.isDarwin
          then pkgs.ghostty-bin
          else pkgs.ghostty
        )
      ];
  };
}
