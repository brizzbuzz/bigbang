{
  config,
  lib,
  ...
}: {
  options.system-limits = {
    enable = lib.mkEnableOption "Enable increased system resource limits";

    fileDescriptors = lib.mkOption {
      type = lib.types.int;
      default = 65536;
      description = "Maximum number of open file descriptors";
    };

    processes = lib.mkOption {
      type = lib.types.int;
      default = 32768;
      description = "Maximum number of processes";
    };
  };

  config = lib.mkIf config.system-limits.enable {
    # Increase systemd default limits for all services
    systemd.settings.Manager = {
      DefaultLimitNOFILE = config.system-limits.fileDescriptors;
      DefaultLimitNPROC = config.system-limits.processes;
    };

    # Set PAM limits for user sessions
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = toString config.system-limits.fileDescriptors;
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = toString config.system-limits.fileDescriptors;
      }
      {
        domain = "*";
        type = "soft";
        item = "nproc";
        value = toString config.system-limits.processes;
      }
      {
        domain = "*";
        type = "hard";
        item = "nproc";
        value = toString config.system-limits.processes;
      }
    ];

    # Increase kernel-level limits
    boot.kernel.sysctl = {
      # Increase maximum number of file handles system-wide
      "fs.nr_open" = lib.mkDefault (config.system-limits.fileDescriptors * 2);
      # Increase maximum number of file handles that can be allocated
      "fs.file-max" = lib.mkDefault (config.system-limits.fileDescriptors * 4);
    };
  };
}
