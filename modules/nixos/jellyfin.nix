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

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the Jellyfin port in the firewall.";
    };
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

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [8096];
  };
}
