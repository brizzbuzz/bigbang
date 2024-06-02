return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters = {
        kdlfmt = {
          command = "kdlfmt",
          args = "-",
          stdin = true,
          inherit = false,
          exit_codes = { 0 },
        },
      },
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofumpt", "goimports" },
        kdl = { "kdlfmt" },
        nix = { "alejandra" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        sql = { "pg_format" },
        templ = { "templ" },
      },
    },
  },
}
