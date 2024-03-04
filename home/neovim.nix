{pkgs, ...}: let
  unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
in {
  home.packages = with pkgs; [
    unstable.htmx-lsp
    kotlin-language-server
    lua-language-server
    nil
    rust-analyzer
    stylua
    tailwindcss-language-server
  ];
}
