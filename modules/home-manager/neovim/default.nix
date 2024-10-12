{pkgs, pkgs-unstable, ...}: {
  imports = [
    ./colorscheme.nix
    ./globals.nix
    ./options.nix
  ];

  programs.nixvim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    plugins = import ./plugins;
    extraPlugins = [pkgs.vimPlugins.supermaven];
    keymaps = import ./keymap.nix;

    extraConfigLua = ''
    require("supermaven-nvim").setup{}
    '';
  };
}
