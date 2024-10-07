{
  osConfig,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  isDesktop = osConfig.host.desktop.enable;
  isDarwin = osConfig.host.isDarwin;
in
  lib.mkIf (isDesktop && !isDarwin)
  {
    home.packages =
      (with pkgs; [
        discord # Chat
        digikam # Photo editor
        mpv # Media player
        spotify # Music
        transmission_4 # Torrent client
        zoom-us # Video conferencing
      ])
      ++ (with pkgs-unstable; [
        brave # Web browser
        grim # Screenshot utility
        gscreenshot # Screenshot utility
        ledger-live-desktop # Ledger Desktop App
        protonmail-desktop # ProtonMail Desktop App
        jetbrains.idea-ultimate # Jetbrains JVM IDE
        jetbrains.rust-rover # Jetbrains Rust IDE
        ladybird # Experimental Web browser
        slurp # Screenshot utility
      ]);
  }
