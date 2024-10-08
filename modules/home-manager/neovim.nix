{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.nixvim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;

    globals.mapleader = " ";

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "macchiato";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      cursorline = true;
      termguicolors = true;
      clipboard = "unnamedplus";
    };
  };
}
