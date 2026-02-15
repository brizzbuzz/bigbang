{
  config,
  lib,
  ...
}: {
  programs.steam.enable = lib.mkIf config.host.roles.desktop true;
}
