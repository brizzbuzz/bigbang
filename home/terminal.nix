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
      kubectl
      k9s
      lazygit
      ripgrep
      starship
      tree
      xh
      zellij
      zoxide
    ];
  };
}
