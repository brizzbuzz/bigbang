{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    floorp
    qutebrowser
  ];
}
