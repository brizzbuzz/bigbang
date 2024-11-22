{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_11;
    kernelParams = ["psmouse.synaptics_intertouch=0"];
    kernel.sysctl = {
      "kernel.perf_event_paranoid" = 1;
      "fs.inotify.max_user_watches" = 999999;
      "fs.inotify.max_user_instances" = 1024;
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
