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
      blender # 3D modeling
      discord # Chat
      digikam # Photo editor
      floorp # Browser du jour
      gimp # Photo editor
      grim # Screenshot utility
      gscreenshot # Screenshot utility
      inkscape # Vector graphics editor
      jetbrains.datagrip # Database IDE
      jetbrains.idea-ultimate # General IDE
      jetbrains.pycharm-professional # Python IDE
      jetbrains.rust-rover # Rust IDE
      ledger-live-desktop # Ledger Desktop App
      mpv # Media player
      slurp # Screenshot utility
      spacedrive # File manager
      spotify # Music
      transmission_4 # Torrent client
      yubioath-flutter # Yubikey GUI
      zoom-us # Video conferencing
    ];
  }
