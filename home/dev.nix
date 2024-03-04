{
  config,
  pkgs,
  ...
}: {
  # TODO: Make this dry
  home.packages = with pkgs;
    if config.os == "macos"
    then [
      cargo # Rust package manager
      gnupg # GPG
      graphviz-nox # GraphViz / Dot
      helmfile # Declarative helm release management
      jdk21 # Java 21 JDK
      kubernetes-helm # Kubernetes "package manager"
      lua # Lua
      rust-analyzer # LSP for Rust
      rustc # Rust Compiler
      tailwindcss # Tailwind CSS Standalone CLI
      yarn # JS Package manager
      zig # Zig stdlib
    ]
    else [
      cargo # Rust package manager
      docker # Whale go brr
      gcc9 # C compiler
      gnumake # Make
      gnupg # GPG
      graphviz-nox # GraphViz / Dot
      helmfile # Declarative helm release management
      jdk21 # Java 21 JDK
      kubernetes-helm # Kubernetes "package manager"
      lldb_9 # Debugger Protocol
      lua # Lua
      nodejs # NodeJS Runtime
      openssl # Crypto lib for SSL and TLS
      pkg-config # Lets packages talk to each other
      rust-analyzer # LSP for Rust
      rustc # Rust Compiler
      tailwindcss # Tailwind CSS Standalone CLI
      tree-sitter # Language Grammar Tool
      wget # Downloads utility
      yarn # JS Package manager
      zig # Zig stdlib
    ];
}
