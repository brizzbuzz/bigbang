{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lgtm.alloy;
in {
  options.lgtm.alloy = {
    enable = lib.mkEnableOption "Enable Grafana Alloy";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.grafana-alloy;
      description = "The Grafana Alloy package to use";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 12345;
      description = "The port for Alloy to listen on";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Alloy configuration file";
      example = lib.literalExpression "./config.alloy";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/alloy";
      description = "Directory where Alloy stores its data";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--disable-reporting"];
      description = "Extra command-line flags for Alloy";
      example = lib.literalExpression ''
        [
          "--disable-reporting"
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Create test executables to verify Alloy works
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "alloy-version" ''
        ${lib.getExe cfg.package} --version
      '')

      (pkgs.writeShellScriptBin "alloy-test-config" ''
        echo "Checking Alloy configuration file..."
        ${lib.getExe cfg.package} check "${cfg.configFile}"
        if [ $? -ne 0 ]; then
          echo "Error in config file"
          exit 1
        fi
        echo "Config passed syntax check!"
      '')

      (pkgs.writeShellScriptBin "alloy-help" ''
        echo "Showing Alloy help (available flags)..."
        ${lib.getExe cfg.package} --help

        echo -e "\nShowing Alloy run help..."
        ${lib.getExe cfg.package} run --help
      '')
    ];

    # Create a data directory for Alloy
    system.activationScripts.createAlloyDataDir = {
      deps = [];
      text = ''
        mkdir -p ${cfg.dataDir}
        chmod 777 ${cfg.dataDir}
      '';
    };

    # Update the systemd service
    systemd.services.alloy = {
      description = "Grafana Alloy";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        # Set the exec command with storage path
        ExecStart = "${lib.getExe cfg.package} run ${cfg.configFile} ${lib.escapeShellArgs ([
            "--server.http.listen-addr=0.0.0.0:${toString cfg.port}"
            "--storage.path=${cfg.dataDir}"
          ]
          ++ cfg.extraFlags)}";

        # Basic restart settings
        Restart = "on-failure";
        RestartSec = "5s";

        # Let systemd manage these directories
        RuntimeDirectory = "alloy";
        StateDirectory = "alloy";
        LogsDirectory = "alloy";
        CacheDirectory = "alloy";

        # Make sure systemd creates these with the right permissions
        RuntimeDirectoryMode = "0755";
        StateDirectoryMode = "0755";
        LogsDirectoryMode = "0755";
        CacheDirectoryMode = "0755";

        # Explicitly set working directory
        WorkingDirectory = cfg.dataDir;

        # Minimal sandboxing
        PrivateTmp = true;
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Add Caddy proxy for Grafana Alloy UI if Caddy is enabled
    services.caddy.virtualHosts = lib.mkIf config.services.caddy.enable {
      "alloy.${config.host.caddy.domain or "localhost"}" = {
        extraConfig = ''
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };
  };
}
