{
  enable = true;
  settings = {
    provider = "claude";
    auto_suggestions_provider = "claude";

    mappings = {
      diff = {
        ours = "co";
        theirs = "ct";
        all_theirs = "ca";
        both = "cb";
        cursor = "cc";
        next = "]x";
        prev = "[x";
      };
      suggestion = {
        accept = "<M-l>";
        next = "<M-]>";
        prev = "<M-[>";
        dismiss = "<C-]>";
      };
      jump = {
        next = "]]";
        prev = "[[";
      };
      submit = {
        normal = "<CR>";
        insert = "<C-s>";
      };
      toggle = {
        default = "<leader>at";
        debug = "<leader>ad";
        hint = "<leader>ah";
        suggestion = "<leader>as";
        repomap = "<leader>aR";
      };
      ask = "<leader>aa";
      edit = "<leader>ae";
      refresh = "<leader>ar";
      focus = "<leader>af";
      sidebar = {
        apply_all = "A";
        apply_cursor = "a";
        switch_windows = "<Tab>";
        reverse_switch_windows = "<S-Tab>";
      };
    };

    claude = {
      endpoint = "https://api.anthropic.com";
      model = "claude-3-5-sonnet-20241022";
      temperature = 0;
      max_tokens = 8000; # Increased from 4096 to match default
      timeout = 30000; # Added timeout setting
    };

    behaviour = {
      auto_suggestions = false;
      auto_set_highlight_group = true;
      auto_set_keymaps = true;
      auto_apply_diff_after_generation = false;
      support_paste_from_clipboard = false;
    };

    windows = {
      position = "right";
      wrap = true;
      width = 50;
      height = 30;
      sidebar_header = {
        enabled = true;
        align = "center";
        rounded = true;
      };
      input = {
        prefix = "> ";
        height = 8;
      };
      edit = {
        border = "rounded";
        start_insert = true;
      };
      ask = {
        floating = false;
        start_insert = true;
        border = "rounded";
        focus_on_apply = "ours";
      };
    };

    repo_map = {
      ignore_patterns = [
        ".git"
        ".worktree"
        "__pycache__"
        "node_modules"
        "target"
        "build"
      ];
    };

    highlights.diff = {
      current = "DiffText";
      incoming = "DiffAdd";
    };

    diff = {
      autojump = true;
      list_opener = "copen";
      override_timeoutlen = 500;
    };

    hints.enabled = true;
  };
}
