{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      discord
      flameshot
      ledger-live-desktop
      spotify
      transmission_4
      zoom-us
    ])
    ++ (with pkgs-unstable; [protonmail-desktop]);

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
