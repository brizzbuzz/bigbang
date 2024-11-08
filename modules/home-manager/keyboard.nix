{pkgs, ...}: {
  home.packages = with pkgs; [
    kanata
    wally-cli
    xorg.xmodmap
    kbt
    keymapp
  ];
}
