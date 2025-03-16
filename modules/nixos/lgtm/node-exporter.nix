{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lgtm.node_exporter;

  # Use the exact path that worked when we tested manually
  nvidiaSmiPath = "/run/current-system/sw/bin/nvidia-smi";
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

    enableGpuMetrics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable NVIDIA GPU metrics collection";
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

    # Conditionally create and enable a custom NVIDIA GPU metrics exporter service
    systemd.services.nvidia-gpu-exporter = lib.mkIf cfg.enableGpuMetrics {
      description = "NVIDIA GPU Metrics Exporter";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        # Use the specific path to nvidia-smi that we know works
        ExecStart = "${pkgs.prometheus-nvidia-gpu-exporter}/bin/nvidia_gpu_exporter --web.listen-address=:9835 --nvidia-smi-command=${nvidiaSmiPath}";
        Restart = "always";
        RestartSec = "10";

        # Use root user for GPU access
        User = "root";
        Group = "root";
      };
    };

    # Add the NVIDIA GPU exporter to the system packages
    environment.systemPackages = lib.mkIf cfg.enableGpuMetrics [
      pkgs.prometheus-nvidia-gpu-exporter
    ];

    # Open firewall for Node Exporter and optionally for NVIDIA GPU exporter
    networking.firewall.allowedTCPPorts = let
      nodeExporterPorts = lib.optional cfg.openFirewall cfg.port;
      gpuExporterPorts = lib.optional (cfg.enableGpuMetrics && cfg.openFirewall) 9835;
    in
      nodeExporterPorts ++ gpuExporterPorts;
  };
}
