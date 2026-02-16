{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.media.jellyfin;
in {
  options.services.media.jellyfin = {
    enable = lib.mkEnableOption "Enable Jellyfin";
  };

  config = lib.mkIf cfg.enable {
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
