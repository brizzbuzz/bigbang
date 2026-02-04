{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.host.ventoy-web;
in {
  options.host.ventoy-web = {
    enable = mkEnableOption "Ventoy Web UI service for USB drive management";

    port = mkOption {
      type = types.port;
      default = 24680;
      description = "Port for the Ventoy web interface";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "IP address to bind the web server to (0.0.0.0 for all interfaces)";
    };
  };

  config = mkIf cfg.enable {
    # Ensure Ventoy package is available
    environment.systemPackages = [pkgs.ventoy];

    # Systemd service for ventoy-web
    systemd.services.ventoy-web = {
      description = "Ventoy Web UI";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ventoy}/bin/ventoy-web -H ${cfg.bindAddress} -p ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";

        # Ventoy needs root access to manage USB devices
        User = "root";
        Group = "root";

        # Security hardening (while still allowing USB access)
        PrivateTmp = true;
        NoNewPrivileges = false; # Ventoy needs full privileges for disk operations
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/dev" "/sys"]; # Need access to USB devices
      };
    };

    # Open firewall for the web interface
    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
