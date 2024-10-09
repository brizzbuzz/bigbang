{
  enable = true;
  settings = {
    theme = "doom";
    config = {
      header = [
        ""
        ""
        ""
        ""
        ""
        ""
        "     .      .         *    .    *  .   ★   .   *     *"
        "  .     *        .       .    *    .      *   .  ★    "
        "    *  .    ∧__∧      .   *   .    .  ★   .    *  .   "
        " .    *    (=^.^=)     *  .  ★   .   *     *  .    *  "
        "   .  *  . /[__]⏜ ٭     .    .      *   .  ★    .     "
        " *    .   /◠◡◠◡◠⏝     .     ∧__∧  .    *    .     *   "
        "   .     *   *    .   *    (=^.^=) .  ★   .    *  .   "
        " .   *  .    *    .   *  . /⏜[__]⏜  *     *  .    *   "
        "   *   .   .    .  *   .  /◠◡◠◡◠⏝ .      *   .  ★     "
        ""
        ""
      ];
      center = [
        {
          icon = "  ";
          icon_hl = "Title";
          desc = "Find File";
          desc_hl = "String";
          key = "f";
          key_hl = "Number";
          action = "Telescope find_files";
        }
        {
          icon = "  ";
          icon_hl = "Title";
          desc = "Recent Files";
          desc_hl = "String";
          key = "r";
          key_hl = "Number";
          action = "Telescope oldfiles";
        }
        {
          icon = "  ";
          icon_hl = "Title";
          desc = "Open Project";
          desc_hl = "String";
          key = "p";
          key_hl = "Number";
          action = "Telescope projects";
        }
        {
          icon = "  ";
          icon_hl = "Title";
          desc = "New File";
          desc_hl = "String";
          key = "n";
          key_hl = "Number";
          action = "enew";
        }
        {
          icon = "  ";
          icon_hl = "Title";
          desc = "Quit Neovim";
          desc_hl = "String";
          key = "q";
          key_hl = "Number";
          action = "quit";
        }
      ];
      footer = [
        ""
        ""
        ""
        ""
        "🚀 Coding in zero gravity! Meow from space! 🐱💻"
        ""
        ""
        ""
        ""
      ];
    };
  };
}
