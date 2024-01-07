{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      alacritty
      atuin
      bat
      bottom
      du-dust
      fzf
      gh
      gitui
      ripgrep
      zellij
      zoxide
    ];
  };
}
