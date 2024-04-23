{pkgs-unstable, ...}: {
  # TODO: Either should install pueue here or verify that it's installed
  systemd.user.services.pueued = {
    description = "Pueue daemon";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs-unstable.pueue}/bin/pueued";
      Restart = "on-failure";
      RestartSec = "1";
      TimeoutStopSec = "0";
    };
  };
}
