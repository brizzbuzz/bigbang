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
      du-dust
      dua
      fastfetch
      fzf
      gh
      gitui
      glow
      k9s
      ripgrep
      tree
      zellij
      zoxide
    ];
  };
}
