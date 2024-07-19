{pkgs, ...}: {
  # TODO: Do I need these here? Think they are mostly neovim related, so should be in neovim.nix?
  home.packages = with pkgs; [
    gnupg # GPG
    # gcc9 # C Compiler TODO: Breaks on mac
    lua # Lua
    nodejs # NodeJS Runtime
    python312 # Base Python Runtime
    pipx # Python
  ];
}
