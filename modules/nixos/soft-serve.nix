{
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  options = {
    soft-serve.enable = lib.mkEnableOption "Enable Soft Serve";
  };
  config = lib.mkIf config.soft-serve.enable {
    systemd.user.services.soft-serve = {
      description = "Soft Serve";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs-unstable.soft-serve}/bin/soft";
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}
