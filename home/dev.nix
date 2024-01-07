{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cargo
    gcc9
    zig
  ];
}
