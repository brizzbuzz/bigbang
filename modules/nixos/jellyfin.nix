{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.host.jellyfin.server.enable {
    services.jellyfin = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];

    networking.firewall.allowedTCPPorts = [8096];
  };
}
