{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      alacritty
      atuin
      bat
      bottom
      difftastic
      du-dust
      dua
      fastfetch
      fzf
      gh
      gitui
      glow
      k9s
      lazygit
      ripgrep
      tree
      zellij
      zoxide
    ];
  };
}
