{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.portfolio;
  portfolioPkg = inputs.hyperbaric.packages.${pkgs.stdenv.hostPlatform.system}.portfolio;
  hasEnvFiles = cfg.environmentFileSecrets != [];
  environmentFiles =
    builtins.map
    (secret:
      lib.attrByPath
      ["services" "onepassword-secrets" "secretPaths" secret]
      (throw ''Portfolio environment secret "${secret}" is not defined in services.onepassword-secrets.secrets'')
      config)
    cfg.environmentFileSecrets;
in {
  options.services.portfolio = {
    enable = lib.mkEnableOption "Enable Hyperbaric portfolio service";
    port = lib.mkOption {
      type = lib.types.int;
      default = 7878;
      description = "Port for the portfolio service";
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Bind address for the portfolio service";
    };
    environmentFileSecrets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        OpNix secret names that resolve to environment files (KEY=VALUE) to include for the portfolio service.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hyperbaric-portfolio = {
      description = "Hyperbaric Portfolio";
      after = ["network.target"] ++ lib.optionals hasEnvFiles ["opnix-secrets.service"];
      requires = lib.optionals hasEnvFiles ["opnix-secrets.service"];
      wantedBy = ["multi-user.target"];

      environment = {
        PORTFOLIO_ADDR = "${cfg.listenAddress}:${toString cfg.port}";
      };

      serviceConfig = {
        EnvironmentFile = environmentFiles;
        ExecStart = "${portfolioPkg}/bin/portfolio";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;

        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
