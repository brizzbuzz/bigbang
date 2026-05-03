{
  config,
  lib,
  pkgs,
  ...
}: let
  isDesktop = config.host.roles.desktop;
in {
  config = lib.mkIf isDesktop {
    services.fprintd.enable = true;

    services.fprintd.tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };

    environment.systemPackages = with pkgs; [
      fprintd
    ];
  };
}
