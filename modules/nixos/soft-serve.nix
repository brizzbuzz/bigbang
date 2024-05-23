{pkgs-unstable, ...}: {
  systemd.user.services.soft-serve = {
    description = "Soft Serve";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs-unstable.soft-serve}/bin/soft-serve";
      Restart = "always";
      RestartSec = "10";
    };
  };
}
