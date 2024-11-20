{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = pkgs.stdenv.isDarwin;
in
  lib.mkIf (isDesktop && !isDarwin)
  {
    home.packages = with pkgs; [
      rclone
      rclone-browser
    ];
  }
