{
  config,
  lib,
  pkgs,
  ...
}:
# lib.mkIf config.host.jellyfin.server.enable {
{
  services.jellyfin = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
