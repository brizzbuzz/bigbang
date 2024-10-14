{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    speedtest.enable = lib.mkEnableOption "Enable Speedtest Server";
  };

  config = lib.mkIf config.speedtest.enable {
    systemd.user.services.speedtest = {
      description = "Speedtest";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.speedtest}/bin/speedtest";
        Restart = "always";
        RestartSec = "10";
        TimeoutStopSec = "0";
      };
    };
  };
}
