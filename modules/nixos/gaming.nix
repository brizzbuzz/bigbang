{
  config,
  lib,
  ...
}: {
  programs.steam.enable = lib.mkIf config.host.desktop.enable true;
}
