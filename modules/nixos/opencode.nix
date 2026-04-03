{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.opencode;
  enabledInstances = lib.filterAttrs (_: instance: instance.enable) cfg.instances;
  opencodeAssets = builtins.path {
    path = ../common/users/config-files/files/opencode;
    name = "opencode-assets";
  };
  opencodeAgentsPath = "${opencodeAssets}/AGENTS.md";
  opencodeCommandsPath = "${opencodeAssets}/commands";
  opencodeSkillsPath = "${opencodeAssets}/skills";

  mkInstanceData = name: instance: let
    serviceName = "opencode-${name}";
    prepareServiceName = "opencode-prepare-${name}";
    serviceUnit = "${serviceName}.service";
    prepareServiceUnit = "${prepareServiceName}.service";

    stateRoot = instance.stateRoot;
    configHome = "${stateRoot}/.config";
    dataHome = "${stateRoot}/.local/share";
    cacheHome = "${stateRoot}/.cache";
    stateHome = "${stateRoot}/.local/state";
    opencodeConfigDir = "${configHome}/opencode";
    opencodeDataDir = "${dataHome}/opencode";
    opencodeCacheDir = "${cacheHome}/opencode";
    opencodeSecretsDir = "${opencodeConfigDir}/secrets";
    sshDir = "${stateRoot}/.ssh";
    sshConfigFile = "${sshDir}/config";
    signingPrivateKeyFile = "${sshDir}/id_ed25519_signing";
    signingPublicKeyFile = "${sshDir}/id_ed25519_signing.pub";
    allowedSignersFile = "${sshDir}/allowed_signers";

    workspaceNamespaces = map (namespace: "${instance.workspaceRoot}/${namespace}") instance.workspaceNamespaces;
    serverPasswordPath = "/var/lib/opnix/secrets/opencode-${name}-server-password";
    sshPrivateKeyPath = "/var/lib/opnix/secrets/opencode-${name}-ssh-private-key";
    sshPublicKeyPath = "/var/lib/opnix/secrets/opencode-${name}-ssh-public-key";
    sshSigningPrivateKeyPath = "/var/lib/opnix/secrets/opencode-${name}-signing-ssh-private-key";
    sshSigningPublicKeyPath = "/var/lib/opnix/secrets/opencode-${name}-signing-ssh-public-key";
    kagiApiKeyPath = "/var/lib/opnix/secrets/kagi-api-key";

    hasDedicatedSigningKey = instance.sshSigningPrivateKeySecretRef != null;
    signingPrivateKeySourcePath =
      if hasDedicatedSigningKey
      then sshSigningPrivateKeyPath
      else sshPrivateKeyPath;
    signingPublicKeySourcePath =
      if hasDedicatedSigningKey
      then sshSigningPublicKeyPath
      else sshPublicKeyPath;

    knownHostsFile = pkgs.writeText "opencode-known-hosts-${name}" (
      lib.concatStringsSep "\n" instance.sshKnownHosts
      + lib.optionalString (instance.sshKnownHosts != []) "\n"
    );

    opencodeConfig = lib.recursiveUpdate {
      "$schema" = "https://opencode.ai/config.json";
      model = instance.model;
      small_model = instance.smallModel;
      autoupdate = false;
      server = {
        port = instance.port;
        hostname = instance.bindAddress;
      };
      permission = {
        skill = {
          "*" = "allow";
        };
        external_directory = {
          "${instance.workspaceRoot}/**" = "allow";
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
        // lib.optionalAttrs instance.enableKagi {
          kagi = {
            type = "local";
            command = ["${pkgs.uv}/bin/uvx" "kagimcp"];
            environment = {
              KAGI_API_KEY = "{file:${opencodeSecretsDir}/kagi-api-key}";
            };
            enabled = true;
          };
        };
    } instance.extraConfig;

    opencodeTuiConfig = {
      "$schema" = "https://opencode.ai/tui.json";
      theme = "opencode";
      scroll_acceleration = {
        enabled = true;
      };
    };

    opencodeConfigFile = (pkgs.formats.json {}).generate "opencode-service-${name}.json" opencodeConfig;
    opencodeTuiConfigFile = (pkgs.formats.json {}).generate "opencode-service-${name}-tui.json" opencodeTuiConfig;
    gitConfigFile = pkgs.writeText "opencode-gitconfig-${name}" ''
          [user]
            name = ${instance.gitName}
            email = ${instance.gitEmail}
      ${lib.optionalString instance.gitSignCommits ''
        signingKey = ${signingPublicKeyFile}
      ''}    [init]
            defaultBranch = main
          [pull]
            rebase = true
          [push]
            autoSetupRemote = true
          [commit]
            gpgSign = ${
        if instance.gitSignCommits
        then "true"
        else "false"
      }
      ${lib.optionalString instance.gitSignCommits ''
        [tag]
          gpgSign = true
        [gpg]
          format = ssh
        [gpg "ssh"]
          program = ${pkgs.openssh}/bin/ssh-keygen
          allowedSignersFile = ${allowedSignersFile}
      ''}    [core]
            editor = hx
    '';
    sshConfig = pkgs.writeText "opencode-ssh-config-${name}" ''
      Host github.com
        Hostname github.com
        User git
        IdentityFile ${sshDir}/id_ed25519
        IdentitiesOnly yes
        UserKnownHostsFile ${sshDir}/known_hosts
        StrictHostKeyChecking ${
        if instance.sshKnownHosts == []
        then "accept-new"
        else "yes"
      }
    '';

    prepareScript = pkgs.writeShellScript "opencode-prepare-${name}" ''
      set -euo pipefail

      install_bin=${pkgs.coreutils}/bin/install
      cp_bin=${pkgs.coreutils}/bin/cp
      rm_bin=${pkgs.coreutils}/bin/rm
      chmod_bin=${pkgs.coreutils}/bin/chmod
      chown_bin=${pkgs.coreutils}/bin/chown

      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg stateRoot}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg configHome}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg opencodeConfigDir}
      "$install_bin" -d -m 0700 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg opencodeSecretsDir}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg "${stateRoot}/.local"}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg dataHome}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg opencodeDataDir}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg stateHome}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg cacheHome}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg opencodeCacheDir}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg instance.workspaceRoot}
      ${lib.concatMapStringsSep "\n" (namespace: ''
          "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg namespace}
        '') workspaceNamespaces}
      "$install_bin" -d -m 0700 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg sshDir}

      "$cp_bin" ${lib.escapeShellArg opencodeConfigFile} ${lib.escapeShellArg "${opencodeConfigDir}/opencode.json"}
      "$cp_bin" ${lib.escapeShellArg opencodeTuiConfigFile} ${lib.escapeShellArg "${opencodeConfigDir}/tui.json"}
      "$cp_bin" ${lib.escapeShellArg opencodeAgentsPath} ${lib.escapeShellArg "${opencodeConfigDir}/AGENTS.md"}
      "$cp_bin" ${lib.escapeShellArg gitConfigFile} ${lib.escapeShellArg "${stateRoot}/.gitconfig"}
      "$cp_bin" ${lib.escapeShellArg sshConfig} ${lib.escapeShellArg sshConfigFile}

      "$rm_bin" -rf ${lib.escapeShellArg "${opencodeConfigDir}/commands"} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg "${opencodeConfigDir}/commands"}
      "$install_bin" -d -m 0750 -o ${instance.user} -g ${instance.group} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}
      "$cp_bin" -R ${lib.escapeShellArg "${opencodeCommandsPath}/."} ${lib.escapeShellArg "${opencodeConfigDir}/commands"}
      "$cp_bin" -R ${lib.escapeShellArg "${opencodeSkillsPath}/."} ${lib.escapeShellArg "${opencodeConfigDir}/skills"}

      ${lib.optionalString instance.enableServerAuth ''
        if [ -f ${lib.escapeShellArg serverPasswordPath} ]; then
          :
        else
          printf '%s\n' 'Missing OpenCode server password secret at ${serverPasswordPath}' >&2
          exit 1
        fi
      ''}

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
      "$chmod_bin" 0600 ${lib.escapeShellArg sshConfigFile}

      ${lib.optionalString instance.gitSignCommits ''
        if [ -f ${lib.escapeShellArg signingPrivateKeySourcePath} ]; then
          "$cp_bin" ${lib.escapeShellArg signingPrivateKeySourcePath} ${lib.escapeShellArg signingPrivateKeyFile}
          "$chmod_bin" 0600 ${lib.escapeShellArg signingPrivateKeyFile}
        else
          printf '%s\n' 'Missing OpenCode signing SSH private key secret at ${signingPrivateKeySourcePath}' >&2
          exit 1
        fi

        if [ -f ${lib.escapeShellArg signingPublicKeySourcePath} ]; then
          "$cp_bin" ${lib.escapeShellArg signingPublicKeySourcePath} ${lib.escapeShellArg signingPublicKeyFile}
          "$chmod_bin" 0644 ${lib.escapeShellArg signingPublicKeyFile}
          printf '%s %s\n' ${lib.escapeShellArg instance.gitEmail} "$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg signingPublicKeyFile})" > ${lib.escapeShellArg allowedSignersFile}
          "$chmod_bin" 0644 ${lib.escapeShellArg allowedSignersFile}
        else
          printf '%s\n' 'Missing OpenCode signing SSH public key secret at ${signingPublicKeySourcePath}' >&2
          exit 1
        fi
      ''}

      if [ -f ${lib.escapeShellArg kagiApiKeyPath} ]; then
        "$cp_bin" ${lib.escapeShellArg kagiApiKeyPath} ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
        "$chmod_bin" 0600 ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
      else
        "$rm_bin" -f ${lib.escapeShellArg "${opencodeSecretsDir}/kagi-api-key"}
      fi

      "$chown_bin" -R ${instance.user}:${instance.group} \
        ${lib.escapeShellArg configHome} \
        ${lib.escapeShellArg "${stateRoot}/.local"} \
        ${lib.escapeShellArg dataHome} \
        ${lib.escapeShellArg stateHome} \
        ${lib.escapeShellArg cacheHome} \
        ${lib.escapeShellArg instance.workspaceRoot} \
        ${lib.escapeShellArg sshDir}

      "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/opencode.json"}
      "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/tui.json"}
      "$chmod_bin" 0644 ${lib.escapeShellArg "${opencodeConfigDir}/AGENTS.md"}
      "$chmod_bin" 0644 ${lib.escapeShellArg "${stateRoot}/.gitconfig"}
      ${lib.optionalString (!instance.gitSignCommits) ''
        "$rm_bin" -f ${lib.escapeShellArg signingPrivateKeyFile} ${lib.escapeShellArg signingPublicKeyFile} ${lib.escapeShellArg allowedSignersFile}
      ''}
    '';

    startScript = pkgs.writeShellScript "opencode-start-${name}" ''
      set -euo pipefail

      ${lib.optionalString instance.enableServerAuth ''
        export OPENCODE_SERVER_PASSWORD="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/server-password")"
      ''}

      exec ${lib.getExe instance.package} web --hostname ${lib.escapeShellArg instance.bindAddress} --port ${toString instance.port}
    '';

    assertionPrefix = "services.opencode.instances.${name}";
    prepareService = lib.nameValuePair prepareServiceName {
      description = "Prepare OpenCode runtime files for ${name}";
      after = ["opnix-secrets.service"];
      requires = ["opnix-secrets.service"];
      before = [serviceUnit];
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
    service = lib.nameValuePair serviceName {
      description = "OpenCode web service for ${name}";
      wantedBy = ["multi-user.target"];
      after = [
        "network-online.target"
        "opnix-secrets.service"
        prepareServiceUnit
      ];
      requires = [
        "network-online.target"
        "opnix-secrets.service"
        prepareServiceUnit
      ];
      environment =
        {
          HOME = stateRoot;
          XDG_CONFIG_HOME = configHome;
          XDG_DATA_HOME = dataHome;
          XDG_CACHE_HOME = cacheHome;
          XDG_STATE_HOME = stateHome;
          OPENCODE_DISABLE_AUTOUPDATE = "true";
          OPENCODE_DISABLE_CLAUDE_CODE = "true";
          GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -F ${sshConfigFile}";
        }
        // lib.optionalAttrs instance.enableServerAuth {
          OPENCODE_SERVER_USERNAME = instance.serverUsername;
        }
        // instance.extraEnvironment;
      path = [
        pkgs.gh
        pkgs.git
        pkgs.nushell
        pkgs.openssh
        pkgs.uv
      ];
      serviceConfig = {
        Type = "simple";
        User = instance.user;
        Group = instance.group;
        WorkingDirectory = instance.workspaceRoot;
        ExecStart = startScript;
        Restart = "on-failure";
        RestartSec = "5s";
        LoadCredential = lib.optional instance.enableServerAuth "server-password:${serverPasswordPath}";
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          stateRoot
          instance.workspaceRoot
        ];
      };
    };
    tmpfilesRules =
      [
        "d ${stateRoot} 0750 ${instance.user} ${instance.group} -"
        "d ${configHome} 0750 ${instance.user} ${instance.group} -"
        "d ${opencodeConfigDir} 0750 ${instance.user} ${instance.group} -"
        "d ${opencodeSecretsDir} 0700 ${instance.user} ${instance.group} -"
        "d ${stateRoot}/.local 0750 ${instance.user} ${instance.group} -"
        "d ${dataHome} 0750 ${instance.user} ${instance.group} -"
        "d ${opencodeDataDir} 0750 ${instance.user} ${instance.group} -"
        "d ${stateHome} 0750 ${instance.user} ${instance.group} -"
        "d ${cacheHome} 0750 ${instance.user} ${instance.group} -"
        "d ${opencodeCacheDir} 0750 ${instance.user} ${instance.group} -"
        "d ${instance.workspaceRoot} 0750 ${instance.user} ${instance.group} -"
        "d ${sshDir} 0700 ${instance.user} ${instance.group} -"
      ]
      ++ map (namespace: "d ${namespace} 0750 ${instance.user} ${instance.group} -") workspaceNamespaces;
    onepasswordSecrets =
      lib.optionalAttrs instance.enableServerAuth {
        "opencodeServerPassword-${name}" = {
          reference = instance.serverPasswordSecretRef;
          path = serverPasswordPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      }
      // {
        "opencodeSshPrivateKey-${name}" = {
          reference = instance.sshPrivateKeySecretRef;
          path = sshPrivateKeyPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (instance.sshPublicKeySecretRef != null) {
        "opencodeSshPublicKey-${name}" = {
          reference = instance.sshPublicKeySecretRef;
          path = sshPublicKeyPath;
          owner = "root";
          group = "root";
          mode = "0644";
        };
      }
      // lib.optionalAttrs (instance.sshSigningPrivateKeySecretRef != null) {
        "opencodeSigningSshPrivateKey-${name}" = {
          reference = instance.sshSigningPrivateKeySecretRef;
          path = sshSigningPrivateKeyPath;
          owner = "root";
          group = "root";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (instance.sshSigningPublicKeySecretRef != null) {
        "opencodeSigningSshPublicKey-${name}" = {
          reference = instance.sshSigningPublicKeySecretRef;
          path = sshSigningPublicKeyPath;
          owner = "root";
          group = "root";
          mode = "0644";
        };
      };
    assertions = [
      {
        assertion = (!instance.enableServerAuth) || instance.serverPasswordSecretRef != null;
        message = "${assertionPrefix}.serverPasswordSecretRef must be set when enableServerAuth is true.";
      }
      {
        assertion = instance.sshPrivateKeySecretRef != null;
        message = "${assertionPrefix}.sshPrivateKeySecretRef must be set.";
      }
      {
        assertion = (!instance.gitSignCommits) || instance.sshPublicKeySecretRef != null;
        message = "${assertionPrefix}.sshPublicKeySecretRef must be set when gitSignCommits is true.";
      }
      {
        assertion = (instance.sshSigningPrivateKeySecretRef == null) == (instance.sshSigningPublicKeySecretRef == null);
        message = "${assertionPrefix}.sshSigningPrivateKeySecretRef and sshSigningPublicKeySecretRef must either both be set or both be null.";
      }
    ];
    firewallPorts = lib.optional instance.openFirewall instance.port;
    onepasswordUsers = [instance.user];
    integrationServices = [prepareServiceName serviceName];
  in {
    inherit
      assertions
      firewallPorts
      integrationServices
      onepasswordSecrets
      onepasswordUsers
      prepareService
      service
      tmpfilesRules
      ;
  };

  instanceData = lib.mapAttrs mkInstanceData enabledInstances;
  instanceValues = lib.attrValues instanceData;
in {
  options.services.opencode = {
    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          enable = lib.mkEnableOption "OpenCode web service instance";

          package = lib.mkPackageOption pkgs "opencode" {};

          user = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Unix user account that runs this OpenCode instance.";
          };

          group = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Unix group used by this OpenCode instance.";
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
            default = "/var/lib/opencode-${name}";
            description = "State root used as HOME for this OpenCode instance.";
          };

          workspaceRoot = lib.mkOption {
            type = lib.types.str;
            default = "/home/${name}/workspace";
            description = "Workspace root where this OpenCode instance operates on repositories.";
          };

          workspaceNamespaces = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["github"];
            description = "Top-level namespace directories created under the workspace root for canonical repo residency.";
          };

          serverUsername = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "HTTP basic auth username for this OpenCode web service.";
          };

          enableServerAuth = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable OpenCode HTTP basic auth using serverUsername and serverPasswordSecretRef.";
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

          sshSigningPrivateKeySecretRef = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional 1Password reference for a dedicated SSH private key used for Git commit signing.";
          };

          sshSigningPublicKeySecretRef = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional 1Password reference for a dedicated SSH public key used for Git commit signing.";
          };

          sshKnownHosts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            example = [
              "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
            ];
            description = "known_hosts lines installed for this OpenCode instance.";
          };

          enableKagi = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the Kagi MCP using the shared /var/lib/opnix/secrets/kagi-api-key secret.";
          };

          model = lib.mkOption {
            type = lib.types.str;
            default = "openai/gpt-5.4";
            description = "Primary model for this OpenCode instance.";
          };

          gitName = lib.mkOption {
            type = lib.types.str;
            default = "Ryan Brink";
            description = "Git user.name for this OpenCode instance.";
          };

          gitEmail = lib.mkOption {
            type = lib.types.str;
            default = "dev@ryanbr.ink";
            description = "Git user.email for this OpenCode instance.";
          };

          gitSignCommits = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this OpenCode instance should sign commits and tags with an SSH signing key.";
          };

          smallModel = lib.mkOption {
            type = lib.types.str;
            default = "openai/gpt-5.3-codex-spark";
            description = "Small model for lightweight OpenCode tasks.";
          };

          extraEnvironment = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
            description = "Additional environment variables for this OpenCode instance.";
          };

          extraConfig = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Additional OpenCode config merged into the generated service config.";
          };
        };
      }));
      default = {};
      description = "Named OpenCode web service instances.";
    };
  };

  config = lib.mkIf (enabledInstances != {}) {
    assertions = lib.flatten (map (instance: instance.assertions) instanceValues);

    services.onepassword-secrets.users = lib.mkAfter (lib.unique (lib.flatten (map (instance: instance.onepasswordUsers) instanceValues)));

    services.onepassword-secrets.secrets = lib.mkMerge (map (instance: instance.onepasswordSecrets) instanceValues);

    services.onepassword-secrets.systemdIntegration.services = lib.mkAfter (lib.flatten (map (instance: instance.integrationServices) instanceValues));

    systemd.tmpfiles.rules = lib.flatten (map (instance: instance.tmpfilesRules) instanceValues);

    systemd.services = lib.listToAttrs (
      lib.flatten (
        map (instance: [
          instance.prepareService
          instance.service
        ])
        instanceValues
      )
    );

    networking.firewall.allowedTCPPorts = lib.unique (lib.flatten (map (instance: instance.firewallPorts) instanceValues));
  };
}
