{
  lib,
  config,
  pkgs,
  ...
}: {
  xdg.portal = lib.mkIf config.host.roles.desktop {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    wlr.enable = true;
  };
}
