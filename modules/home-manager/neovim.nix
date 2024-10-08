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

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>sf" = "find_files";
        "<leader>sg" = "live_grep";
        "<leader>sb" = "buffers";
        "<leader>sh" = "help_tags";
      };
      extensions = {
        fzf-native = {
          enable = true;
          settings = {
            fuzzy = true;
            override_generic_sorter = true;
            override_file_sorter = true;
            case_mode = "smart_case";
          };
        };
      };
    };

    plugins.web-devicons.enable = true;
  };
}
