{
  enable = true;

  servers = {
    gleam.enable = true;
    gopls.enable = true;
    nixd.enable = true;
    nushell.enable = true;
  };

  keymaps = {
    diagnostic = {
      # Goto previous diagnostic in buffer
      "<leader>k" = "vim.diagnostic.goto_prev";
      # Goto next diagnostic in buffer
      "<leader>j" = "vim.diagnostic.goto_next";
    };

    lspBuf = {
      # Displays hover information about the symbol under the cursor
      "K" = "vim.lsp.buf.hover";
      # Jump to definition
      "gd" = "vim.lsp.buf.definition";
      # Jump to declaration
      "gD" = "vim.lsp.buf.declaration";
      # Lists all the implementations for the symbol under the cursor
      "gi" = "vim.lsp.buf.implementation";
      # Displays a function's signature information
      "<C-k>" = "vim.lsp.buf.signature_help";
      # Renames all references to the symbol under the cursor
      "<F2>" = "vim.lsp.buf.rename";
      # Selects a code action available at the current cursor position
      "<F4>" = "vim.lsp.buf.code_action";
      # Show diagnostics in a floating window
      "gl" = "vim.diagnostic.open_float";
    };
  };
}
