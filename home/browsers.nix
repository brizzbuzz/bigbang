{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    floorp
    polypane
    qutebrowser
  ];
}
