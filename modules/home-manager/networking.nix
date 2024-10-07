{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = osConfig.host.isDarwin;
in
  lib.mkIf (isDesktop && !isDarwin)
  {
    home.packages = with pkgs; [
      connman
      iwd
      iwgtk
      tailscale
    ];
  }
