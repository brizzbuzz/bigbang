{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = pkgs.stdenv.isDarwin;
in
  lib.mkIf (isDesktop && !isDarwin)
  {
    home.packages = with pkgs; [
      # Broken??
      # blender # 3D modeling
      discord # Chat
      digikam # Photo editor
      floorp # Browser du jour
      gimp # Photo editor
      inkscape # Vector graphics editor
      jetbrains.datagrip # Database IDE
      jetbrains.idea-ultimate # General IDE
      jetbrains.pycharm-professional # Python IDE
      jetbrains.rust-rover # Rust IDE
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
