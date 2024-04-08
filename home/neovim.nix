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
      nixd
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
    ++ (with pkgs-unstable; [
      htmx-lsp
      gopls
    ]);
}
