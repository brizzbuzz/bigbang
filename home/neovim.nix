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
      lldb_9
      lua-language-server
      nil
      nodePackages_latest.jsonlint
      pylyzer
      pyright
      rust-analyzer
      rustfmt
      stylua
      tailwindcss-language-server
      tree-sitter
      vale
      vscode-langservers-extracted
      vscode-extensions.ms-vscode.cpptools
      vscode-extensions.vadimcn.vscode-lldb
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
