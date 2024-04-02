{...}: {
  boot = {
    kernel.sysctl = {
      "kernel.perf_event_paranoid" = 1;
    };

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
