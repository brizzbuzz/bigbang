{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf osConfig.host.desktop.enable
    [
      steam
    ];
}
