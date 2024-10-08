{
  enable = true;
  settings = {
    default_file_explorer = true;
    columns = [
      "icon"
      "permissions"
      "size"
      "mtime"
    ];
    view_options = {
      show_hidden = true;
    };
    float = {
      padding = 2;
      max_width = 80;
      max_height = 30;
      border = "rounded";
    };
    use_default_keymaps = false;
    keymaps = {
      "g?" = "actions.show_help";
      "<CR>" = "actions.select";
      "<C-s>" = "actions.select_vsplit";
      "<C-h>" = "actions.select_split";
      "<C-t>" = "actions.select_tab";
      "<C-p>" = "actions.preview";
      "<C-c>" = "actions.close";
      "<C-r>" = "actions.refresh";
      "-" = "actions.parent";
      "_" = "actions.open_cwd";
      "`" = "actions.cd";
      "~" = "actions.tcd";
      "gs" = "actions.change_sort";
      "gx" = "actions.open_external";
      "g." = "actions.toggle_hidden";
    };
  };
}
