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
  ];
}
