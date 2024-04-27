{pkgs, ...}: {
  # TODO: Do I need these here? Think they are mostly neovim related, so should be in neovim.nix?
  home.packages = with pkgs; [
    gnupg # GPG
    gcc9 # C Compiler
    lua # Lua
    nodejs # NodeJS Runtime
  ];
}
