{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra # Nix Formatter
    htmx-lsp # HTMX Language Server
    lua-language-server # Lua Language Server
    nil # Nix Language Server
    pgformatter # Postgres Formatter
    postgres-lsp # Postgres Language Server
    pyright # Python Language Server
    stylua # Lua formatter
    ruff-lsp # Ruff Language Server
    rust-analyzer # Rust language server
    sqlfluff # SQL Linter
    tailwindcss-language-server # Tailwind CSS Language Server
    terraform-ls # Terraform Language Server
    tree-sitter
    vscode-langservers-extracted # Various Language Servers
    nodePackages.vscode-json-languageserver # VSCode JSON Language Server
  ];
}
