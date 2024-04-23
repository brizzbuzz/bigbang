{pkgs, ...}: {
  systemd.user.services.espanso = {
    description = "Espanso daemon";
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.espanso}/bin/espanso start";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
