{
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
}
