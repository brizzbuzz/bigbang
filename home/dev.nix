{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cargo # Rust package manager
    docker # Whale go brr
    gcc9 # C compiler
    graphviz-nox # GraphViz / Dot
    helmfile # Declarative helm release management
    jdk21 # Java 21 JDK
    kubernetes-helm # Kubernetes "package manager"
    lldb_9 # Debugger Protocol
    lua # Lua
    openssl # Crypto lib for SSL and TLS
    pkg-config # Lets packages talk to each other
    rust-analyzer # LSP for Rust
    rustc # Rust Compiler
    zig # Zig stdlib
  ];
}
