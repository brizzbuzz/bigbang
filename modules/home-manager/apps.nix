{
  osConfig,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
lib.mkIf osConfig.host.desktop.enable
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
      ledger-live-desktop # Ledger Desktop App
      protonmail-desktop # ProtonMail Desktop App
      jetbrains.idea-ultimate # Jetbrains JVM IDE
      jetbrains.rust-rover # Jetbrains Rust IDE
    ]);

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "op read op://private/Spotify/username -n";
        password = "op read op://private/Spotify/password -n";
        device_name = "frame";
      };
    };
  };
}
