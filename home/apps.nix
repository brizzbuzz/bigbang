{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ledger-live-desktop
    transmission_4
  ];
}
