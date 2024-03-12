{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    brave
    floorp
    polypane
    qutebrowser
  ];
}
