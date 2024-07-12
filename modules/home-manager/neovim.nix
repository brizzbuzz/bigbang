{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra # Nix Formatter
    lua-language-server # Lua Language Server
    nil # Nix Language Server
    stylua # Lua formatter
    terraform-ls # Terraform Language Server
    tree-sitter
    nodePackages.vscode-json-languageserver # VSCode JSON Language Server
  ];
}
