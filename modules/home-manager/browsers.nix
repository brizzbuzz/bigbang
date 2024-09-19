{pkgs, ...}: {
  home.packages = with pkgs; [
    brave
    ladybird
    polypane
    qutebrowser
    vivaldi
  ];
}
