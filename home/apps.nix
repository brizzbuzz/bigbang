{
  config,
  pkgs,
  ...
}: {
  home.packages =
    (with pkgs; [
      _1password
      ledger-live-desktop
      transmission_4
    ])
    ++ (
      if config.os == "macos"
      then []
      else
        with pkgs; [
          _1password-gui
          discord
          spotify
        ]
    );
}
