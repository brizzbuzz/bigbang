{
  config,
  lib,
  ...
}: let
  cfg = config.lgtm.node_exporter;
in {
  options.lgtm.node_exporter = {
    enable = lib.mkEnableOption "Enable Prometheus Node Exporter";

    port = lib.mkOption {
      type = lib.types.int;
      default = 9100;
      description = "The port for Node Exporter to listen on";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for Node Exporter";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra command-line flags for Node Exporter";
      example = lib.literalExpression ''
        [
          "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
          "--no-collector.hwmon"
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = cfg.port;
      enabledCollectors = [
        "systemd"
        "cpu"
        "filesystem"
        "meminfo"
        "netdev"
        "diskstats"
        "loadavg"
      ];
      extraFlags = cfg.extraFlags;
    };

    # Open firewall for Node Exporter if requested
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
