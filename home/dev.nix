{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs;
      [
        cargo # Rust package manager
        gnupg # GPG
        graphviz-nox # GraphViz / Dot
        helmfile # Declarative helm release management
        jdk21 # Java 21 JDK
        kubernetes-helm # Kubernetes "package manager"
        lua # Lua
        nodejs # NodeJS Runtime
        rust-analyzer # LSP for Rust
        rustc # Rust Compiler
        tailwindcss # Tailwind CSS Standalone CLI
        tree-sitter # Language Grammar Tool
        wget # Downloads utility
        yarn # JS Package manager
        zig # Zig stdlib
      ]
      ++ (
        if config.os == "macos"
        then []
        else [
          docker # Whale go brr
          gcc9 # C compiler
          gnumake # Make
          lldb_9 # Debugger Protocol
          openssl # Crypto lib for SSL and TLS
          pkg-config # Lets packages talk to each other
        ]
      ))
    ++ (
      with pkgs-unstable; [
        gleam # Statically typed lang for Erlang VM
      ]
    );
}
