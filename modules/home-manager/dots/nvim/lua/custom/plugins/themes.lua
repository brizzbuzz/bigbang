return {
  {
    "folke/tokyonight.nvim",
    -- lazy = false,
    -- priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- lazy = false,
    -- priority = 1000,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "moon",
      dark_variant = "moon",
      dim_inactive_windows = true,
      extend_background_behind_borders = true,
    },
    config = function()
      vim.cmd.colorscheme("rose-pine-moon")
      vim.cmd.hi("Comment gui=none")
    end,
  },
}
