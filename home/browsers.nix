{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    brave
    polypane
    qutebrowser
    vivaldi
  ];
}
