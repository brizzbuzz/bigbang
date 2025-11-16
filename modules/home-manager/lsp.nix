{pkgs, ...}: {
  home.packages = with pkgs; [
    gopls
    rust-analyzer
    zls
    nodePackages.typescript-language-server
    pyright
    nil
  ];
}
