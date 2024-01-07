{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      alacritty
      atuin
      bat
      bottom
      du-dust
      fastfetch
      fzf
      gh
      gitui
      glow
      k9s
      ripgrep
      zellij
      zoxide
    ];
  };
}
