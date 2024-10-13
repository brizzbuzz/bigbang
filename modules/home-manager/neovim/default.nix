{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.nixvim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;

    colorschemes = import ./colorscheme.nix;
    globals = import ./globals.nix;
    keymaps = import ./keymap.nix;
    opts = import ./options.nix;

    plugins = import ./plugins;
    extraPlugins = [pkgs.vimPlugins.supermaven];

    # TODO: Create custom plugin for nixvim
    extraConfigLua = ''
      require("supermaven-nvim").setup{}
    '';
  };
}
