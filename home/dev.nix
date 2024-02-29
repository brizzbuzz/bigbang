{
  config,
  pkgs,
  ...
}: {
  # TODO: Make this dry
  home.packages = with pkgs; if config.os == "macos" then [
    cargo # Rust package manager
    graphviz-nox # GraphViz / Dot
    helmfile # Declarative helm release management
    jdk21 # Java 21 JDK
    kubernetes-helm # Kubernetes "package manager"
    lua # Lua
    rust-analyzer # LSP for Rust
    rustc # Rust Compiler
    zig # Zig stdlib
  ] else [
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
    tailwindcss # Tailwind CSS Standalone CLI
    zig # Zig stdlib
  ];
}
