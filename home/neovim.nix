{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      clippy
      kotlin-language-server
      lua-language-server
      nil
      nodePackages_latest.jsonlint
      pylyzer
      pyright
      rust-analyzer
      rustfmt
      stylua
      tailwindcss-language-server
      vale
    ])
    ++ (
      if config.os == "nixos"
      then
        (with pkgs-unstable; [
          htmx-lsp # Can't currently compile on Mac due to C compiler issues :(
        ])
      else []
    );
}
