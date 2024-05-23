{
  pkgs-unstable,
  lib,
  ...
}: {
  options = {
    soft-serve.enable = lib.mkEnableOption "Enable Soft Serve";
  };
  config = {
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
  };
}
