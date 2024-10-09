{
  pkgs,
  pkgs-unstable,
  ...
}: {

  imports = [
    ./colorscheme.nix
    ./globals.nix
    ./options.nix
  ];

  programs.nixvim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    plugins = import ./plugins;
    keymaps = import ./keymap.nix;
  };
}
