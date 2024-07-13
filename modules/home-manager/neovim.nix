{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra # Nix Formatter
    htmx-lsp # HTMX Language Server
    lua-language-server # Lua Language Server
    nil # Nix Language Server
    stylua # Lua formatter
    rust-analyzer # Rust language server
    tailwindcss-language-server # Tailwind CSS Language Server
    terraform-ls # Terraform Language Server
    tree-sitter
    vscode-langservers-extracted # Various Language Servers
    nodePackages.vscode-json-languageserver # VSCode JSON Language Server
  ];
}
