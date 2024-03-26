{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      wally-cli
      xorg.xmodmap
    ])
    ++ (with pkgs-unstable; [
      keymapp
    ]);
}
