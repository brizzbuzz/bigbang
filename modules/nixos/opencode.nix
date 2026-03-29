{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.opencode;

  homeDir = cfg.stateRoot;
  configHome = "${homeDir}/.config";
  dataHome = "${homeDir}/.local/share";
  cacheHome = "${homeDir}/.cache";
  stateHome = "${homeDir}/.local/state";
  opencodeConfigDir = "${configHome}/opencode";
  opencodeDataDir = "${dataHome}/opencode";
  opencodeCacheDir = "${cacheHome}/opencode";
  opencodeSecretsDir = "${opencodeConfigDir}/secrets";
  sshDir = "${homeDir}/.ssh";

  serverPasswordPath = "/var/lib/opnix/secrets/opencode-server-password";
  sshPrivateKeyPath = "/var/lib/opnix/secrets/opencode-ssh-private-key";
  sshPublicKeyPath = "/var/lib/opnix/secrets/opencode-ssh-public-key";
  kagiApiKeyPath = "/var/lib/opnix/secrets/kagi-api-key";
  knownHostsFile = pkgs.writeText "opencode-known-hosts" (
    lib.concatStringsSep "\n" cfg.sshKnownHosts
    + lib.optionalString (cfg.sshKnownHosts != []) "\n"
  );
  opencodeAssets = builtins.path {
    path = ../common/users/config-files/files/opencode;
    name = "opencode-assets";
  };

  opencodeAgentsPath = "${opencodeAssets}/AGENTS.md";
  opencodeCommandsPath = "${opencodeAssets}/commands";
  opencodeSkillsPath = "${opencodeAssets}/skills";

  opencodeConfig =
    lib.recursiveUpdate {
      "$schema" = "https://opencode.ai/config.json";
      model = cfg.model;
      small_model = cfg.smallModel;
      autoupdate = false;
      server = {
        port = cfg.port;
        hostname = cfg.bindAddress;
      };
      permission = {
        skill = {
          "*" = "allow";
        };
        external_directory = {
          "${cfg.workspaceRoot}/**" = "allow";
        };
      };
      mcp =
        {
          linear = {
            type = "remote";
            url = "https://mcp.linear.app/mcp";
          };
          nixos = {
            type = "local";
            command = ["${pkgs.uv}/bin/uvx" "mcp-nixos"];
            enabled = true;
          };
          nushell = {
            type = "local";
            command = ["${lib.getExe pkgs.nushell}" "--mcp"];
            enabled = true;
          };
        }
        // lib.optionalAttrs cfg.enableKagi {
          kagi = {
            type = "local";
            command = ["${pkgs.uv}/bin/uvx" "kagimcp"];
            environment = {
              KAGI_API_KEY = "{file:${opencodeSecretsDir}/kagi-api-key}";
            };
            enabled = true;
          };
        };
    }
    cfg.extraConfig;

  opencodeTuiConfig = {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "opencode";
    scroll_acceleration = {
      enabled = true;
    };
  };

  opencodeConfigFile = (pkgs.formats.json {}).generate "opencode-service.json" opencodeConfig;
  opencodeTuiConfigFile = (pkgs.formats.json {}).generate "opencode-service-tui.json" opencodeTuiConfig;
  gitConfigFile = pkgs.writeText "opencode-gitconfig" ''
    [user]
      name = ${cfg.gitName}
      email = ${cfg.gitEmail}
    [init]
      defaultBranch = main
    [pull]
      rebase = true
    [push]
      autoSetupRemote = true
    [commit]
      gpgSign = false
    [core]
      editor = hx
  '';

  prepareScript = pkgs.writeShellScript "opencode-prepare" ''
    set -euo pipefail

    install_bin=${pkgs.coreutils}/bin/install
    cp_bin=${pkgs.coreutils}/bin/cp
    rm_bin=${pkgs.coreutils}/bin/rm
    chown_bin=${pkgs.coreutils}/bin/chown
    chmod_bin=${pkgs.coreutils}/bin/chmod

    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg homeDir}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg configHome}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg opencodeConfigDir}
    "$install_bin" -d -m 0700 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg opencodeSecretsDir}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg "${homeDir}/.local"}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg "${dataHome}"}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg opencodeDataDir}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg stateHome}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg cacheHome}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg opencodeCacheDir}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg cfg.workspaceRoot}
    "$install_bin" -d -m 0700 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg sshDir}

    "$cp_bin" ${lib.escapeShellArg opencodeConfigFile} ${lib.escapeShellArg "${opencodeConfigDir}/opencode.json"}
    "$cp_bin" ${lib.escapeShellArg opencodeTuiConfigFile} ${lib.escapeShellArg "${opencodeConfigDir}/tui.json"}
    "$cp_bin" ${lib.escapeShellArg opencodeAgentsPath} ${lib.escapeShellArg "${opencodeConfigDir}/AGENTS.md"}
    "$cp_bin" ${lib.escapeShellArg gitConfigFile} ${lib.escapeShellArg "${homeDir}/.gitconfig"}

    "$rm_bin" -rf ${lib.escapeShellArg "${opencodeConfigDir}/commands"} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg "${opencodeConfigDir}/commands"}
    "$install_bin" -d -m 0750 -o ${cfg.user} -g ${cfg.group} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}
    "$cp_bin" -R ${lib.escapeShellArg "${opencodeCommandsPath}/."} ${lib.escapeShellArg "${opencodeConfigDir}/commands"}
    "$cp_bin" -R ${lib.escapeShellArg "${opencodeSkillsPath}/."} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}

    if [ -f ${lib.escapeShellArg serverPasswordPath} ]; then
      :
    else
      printf '%s\n' 'Missing OpenCode server password secret at ${serverPasswordPath}' >&2
      exit 1
    fi

    if [ -f ${lib.escapeShellArg sshPrivateKeyPath} ]; then
      "$cp_bin" ${lib.escapeShellArg sshPrivateKeyPath} ${lib.escapeShellArg "${sshDir}/id_ed25519"}
      "$chmod_bin" 0600 ${lib.escapeShellArg "${sshDir}/id_ed25519"}
    else
      printf '%s\n' 'Missing OpenCode SSH private key secret at ${sshPrivateKeyPath}' >&2
      exit 1
    fi

    if [ -f ${lib.escapeShellArg sshPublicKeyPath} ]; then
      "$cp_bin" ${lib.escapeShellArg sshPublicKeyPath} ${lib.escapeShellArg "${sshDir}/id_ed25519.pub"}
      "$chmod_bin" 0644 ${lib.escapeShellArg "${sshDir}/id_ed25519.pub"}
    fi

    "$cp_bin" ${lib.escapeShellArg knownHostsFile} ${lib.escapeShellArg "${sshDir}/known_hosts"}
    "$chmod_bin" 0644 ${lib.escapeShellArg "${sshDir}/known_hosts"}

    if [ -f ${lib.escapeShellArg kagiApiKeyPath} ]; then
      "$cp_bin" ${lib.escapeShellArg kagiApiKeyPath} ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
      "$chmod_bin" 0600 ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
    else
      "$rm_bin" -f ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
    fi

    "$chown_bin" -R ${cfg.user}:${cfg.group} \
      ${lib.escapeShellArg configHome} \
      ${lib.escapeShellArg "${homeDir}/.local"} \
      ${lib.escapeShellArg "${dataHome}"} \
      ${lib.escapeShellArg stateHome} \
      ${lib.escapeShellArg cacheHome} \
      ${lib.escapeShellArg cfg.workspaceRoot} \
      ${lib.escapeShellArg sshDir}

    "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/opencode.json"}
    "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/tui.json"}
    "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/AGENTS.md"}
    "$chmod_bin" 0644 ${lib.escapeShellArg "${homeDir}/.gitconfig"}
  '';

  startScript = pkgs.writeShellScript "opencode-start" ''
    set -euo pipefail

    export OPENCODE_SERVER_PASSWORD="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/server-password")"

    exec ${lib.getExe cfg.package} web --hostname ${lib.escapeShellArg cfg.bindAddress} --port ${toString cfg.port}
  '';
in {
  options.services.opencode = {
    enable = lib.mkEnableOption "OpenCode web service";

    package = lib.mkPackageOption pkgs "opencode" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "User account for the OpenCode daemon.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "Group for the OpenCode daemon.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for the OpenCode web server to listen on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "Port for the OpenCode web server.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the configured OpenCode port in the firewall.";
    };

    stateRoot = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opencode";
      description = "State root used as HOME for the OpenCode daemon.";
    };

    workspaceRoot = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opencode/workspace";
      description = "Workspace root where the OpenCode daemon operates on repositories.";
    };

    serverUsername = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "HTTP basic auth username for the OpenCode web service.";
    };

    serverPasswordSecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the OpenCode server password.";
    };

    sshPrivateKeySecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the OpenCode SSH private key.";
    };

    sshPublicKeySecretRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "1Password reference for the OpenCode SSH public key.";
    };

    sshKnownHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [
        "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
      ];
      description = "known_hosts lines installed for the OpenCode service account.";
    };

    enableKagi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kagi MCP using the shared /var/lib/opnix/secrets/kagi-api-key secret.";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "openai/gpt-5.4";
      description = "Primary model for the OpenCode daemon.";
    };

    gitName = lib.mkOption {
      type = lib.types.str;
      default = "Ryan Brink";
      description = "Git user.name for the OpenCode service account.";
    };

    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "dev@ryanbr.ink";
      description = "Git user.email for the OpenCode service account.";
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = "openai/gpt-5.3-codex-spark";
      description = "Small model for lightweight OpenCode tasks.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables for the OpenCode service.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional OpenCode config merged into the generated service config.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.serverPasswordSecretRef != null;
        message = "services.opencode.serverPasswordSecretRef must be set.";
      }
      {
        assertion = cfg.sshPrivateKeySecretRef != null;
        message = "services.opencode.sshPrivateKeySecretRef must be set.";
      }
    ];

    users.groups.${cfg.group} = {};

    users.users.${cfg.user} = {
      isSystemUser = true;
      home = homeDir;
      createHome = false;
      group = cfg.group;
      shell = pkgs.bashInteractive;
    };

    services.onepassword-secrets.users = lib.mkAfter [cfg.user];

    services.onepassword-secrets.secrets =
      {
        opencodeServerPassword = {
          reference = cfg.serverPasswordSecretRef;
          path = serverPasswordPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };

        opencodeSshPrivateKey = {
          reference = cfg.sshPrivateKeySecretRef;
          path = sshPrivateKeyPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (cfg.sshPublicKeySecretRef != null) {
        opencodeSshPublicKey = {
          reference = cfg.sshPublicKeySecretRef;
          path = sshPublicKeyPath;
          owner = "root";
          group = "root";
          mode = "0644";
        };
      };

    services.onepassword-secrets.systemdIntegration.services = lib.mkAfter [
      "opencode-prepare"
      "opencode"
    ];

    systemd.tmpfiles.rules = [
      "d ${homeDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${configHome} 0750 ${cfg.user} ${cfg.group} -"
      "d ${opencodeConfigDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${opencodeSecretsDir} 0700 ${cfg.user} ${cfg.group} -"
      "d ${homeDir}/.local 0750 ${cfg.user} ${cfg.group} -"
      "d ${dataHome} 0750 ${cfg.user} ${cfg.group} -"
      "d ${opencodeDataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${stateHome} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cacheHome} 0750 ${cfg.user} ${cfg.group} -"
      "d ${opencodeCacheDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.workspaceRoot} 0750 ${cfg.user} ${cfg.group} -"
      "d ${sshDir} 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.opencode-prepare = {
      description = "Prepare OpenCode service runtime files";
      after = ["opnix-secrets.service"];
      requires = ["opnix-secrets.service"];
      before = ["opencode.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        RemainAfterExit = true;
      };
      script = ''
        ${prepareScript}
      '';
    };

    systemd.services.opencode = {
      description = "OpenCode web service";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
        "opnix-secrets.service"
        "opencode-prepare.service"
      ];
      requires = [
        "network-online.target"
        "opnix-secrets.service"
        "opencode-prepare.service"
      ];
      environment =
        {
          HOME = homeDir;
          XDG_CONFIG_HOME = configHome;
          XDG_DATA_HOME = dataHome;
          XDG_CACHE_HOME = cacheHome;
          XDG_STATE_HOME = stateHome;
          OPENCODE_DISABLE_AUTOUPDATE = "true";
          OPENCODE_DISABLE_CLAUDE_CODE = "true";
          OPENCODE_SERVER_USERNAME = cfg.serverUsername;
          GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -F /dev/null -i ${sshDir}/id_ed25519 -o UserKnownHostsFile=${sshDir}/known_hosts -o StrictHostKeyChecking=${
            if cfg.sshKnownHosts == []
            then "accept-new"
            else "yes"
          }";
        }
        // cfg.extraEnvironment;
      path = [
        pkgs.git
        pkgs.nushell
        pkgs.openssh
        pkgs.uv
      ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workspaceRoot;
        ExecStart = startScript;
        Restart = "on-failure";
        RestartSec = "5s";
        LoadCredential = ["server-password:${serverPasswordPath}"];
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [homeDir];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
