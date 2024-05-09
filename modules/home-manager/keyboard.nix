{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      kanata
      wally-cli
      xorg.xmodmap
    ])
    ++ (with pkgs-unstable; [
      kbt
      keymapp
    ]);
}
