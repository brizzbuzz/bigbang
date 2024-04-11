{
  lib,
  config,
  pkgs,
  ...
}: {
  xdg.portal = lib.mkIf config.host.desktop.enable {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    wlr.enable = true;
  };
}
