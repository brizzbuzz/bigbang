{
  pkgs,
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
      unitConfig = {
        Description = "Soft Serve";
        After = ["network-online.target"];
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.soft-serve}/bin/soft serve";
        Restart = "always";
        RestartSec = "10";
        # WorkingDirectory = "/var/local/lib/soft-serve";
      };
    };
  };
}
