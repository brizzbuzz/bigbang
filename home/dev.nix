{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cargo # Rust package manager
    gcc9 # C compiler
    graphviz-nox # GraphViz / Dot
    helmfile # Declarative helm release management
    jdk21 # Java 21 JDK
    kubernetes-helm # Kubernetes "package manager"
    lldb_9 # Debugger Protocol
    lua # Lua
    rust-analyzer # LSP for Rust
    zig # Zig stdlib
  ];
}
