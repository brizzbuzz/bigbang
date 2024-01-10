{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    _1password
    _1password-gui
    discord
    ledger-live-desktop
    spotify
  ];
}
