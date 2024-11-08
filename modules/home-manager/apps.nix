{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = osConfig.host.isDarwin;
in
  lib.mkIf (isDesktop && !isDarwin)
  {
    home.packages = with pkgs; [
      blender # 3D modeling
      discord # Chat
      digikam # Photo editor
      floorp # Browser du jour
      gimp # Photo editor
      inkscape # Vector graphics editor
      mpv # Media player
      spotify # Music
      transmission_4 # Torrent client
      zoom-us # Video conferencing
      grim # Screenshot utility
      gscreenshot # Screenshot utility
      ledger-live-desktop # Ledger Desktop App
      slurp # Screenshot utility
    ];
  }
