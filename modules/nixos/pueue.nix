{pkgs, ...}: {
  systemd.user.services.pueued = {
    description = "Pueue daemon";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.pueue}/bin/pueued";
      Restart = "on-failure";
      RestartSec = "1";
      TimeoutStopSec = "0";
    };
  };
}
