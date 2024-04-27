{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf config.host.desktop.enable [
      libreoffice-qt
      hunspell
    ];
}
