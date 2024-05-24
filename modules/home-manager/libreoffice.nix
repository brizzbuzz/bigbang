{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf osConfig.host.desktop.enable [
      libreoffice-qt
      hunspell
    ];
}
