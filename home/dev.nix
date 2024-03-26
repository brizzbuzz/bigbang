{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      direnv # Do cool stuff in X directory
      docker # Whale go brr
      gnupg # GPG
      gcc9 # C Compiler
      lua # Lua
      nodejs # NodeJS Runtime
      rebar3 # Erlang build tool
      rr # Records nondeterministic executions and debugs them deterministically
      rustc # Rust Compiler
      wget # Downloads utility
    ])
    ++ (
      with pkgs-unstable; [
        devenv # Developer environments built on top of Flakes
        gleam # Statically typed lang for Erlang VM
        jetbrains.idea-ultimate # Jetbrains IDE
        jetbrains.rust-rover
      ]
    );
}
