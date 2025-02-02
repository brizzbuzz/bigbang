{...}: {
  programs.nixvim = {
    enable = true;
    colorschemes = import ./colorscheme.nix;
    globals = import ./globals.nix;
    keymaps = import ./keymap.nix;
    opts = import ./options.nix;
    plugins = import ./plugins;
  };
}
