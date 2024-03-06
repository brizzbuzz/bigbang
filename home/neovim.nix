{pkgs, pkgs-unstable, ...}: {
  home.packages = (with pkgs; [
    kotlin-language-server
    lua-language-server
    nil
    rust-analyzer
    stylua
    tailwindcss-language-server
  ]) ++ (with pkgs-unstable; [
    htmx-lsp
  ]);
}
