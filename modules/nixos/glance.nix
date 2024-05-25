{
  config,
  lib,
  glance,
  ...
}: {
  options = {
    glance.enable = lib.mkEnableOption "Enable Glance Dashboard";
  };

  config = lib.mkIf config.glance.enable {
    environment.etc.glance.text = builtins.readFile ./glance.yml;
    systemd.user.services.glance = {
      description = "Glance";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${glance}/bin/glance -config /etc/glance";
        Restart = "on-failure";
        RestartSec = "10";
        TimeoutStopSec = "0";
      };
    };
  };
}
