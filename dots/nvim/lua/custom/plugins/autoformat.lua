return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofumpt", "goimports" },
        nix = { "alejandra" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        templ = { "templ" },
      },
    },
  },
}
