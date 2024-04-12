{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      gnupg # GPG
      gcc9 # C Compiler
      lua # Lua
      nodejs # NodeJS Runtime
    ])
    ++ (
      with pkgs-unstable; [
        jetbrains.idea-ultimate # Jetbrains IDE
        jetbrains.rust-rover
      ]
    );
}
