{pkgs, pkgs-unstable, ...}: {
  home.packages = (with pkgs; [
    wally-cli
  ]) ++ (with pkgs-unstable; [
    keymapp
  ]);
}
