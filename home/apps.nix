{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    discord
    ledger-live-desktop
    spotify
    transmission_4
    zoom-us
  ];

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
