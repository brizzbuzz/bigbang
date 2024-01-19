{
  config,
  pkgs,
  ...
}: 

{
  home = {
    packages = with pkgs; [
      alacritty # Terminal Emulator
      atuin # Magical Shell History
      bat # Sexy cat
      bottom # TUI System Monitoring
      difftastic # Sytnax aware diff tool
      du-dust # TUI folder size tool
      dua # TUI disk space tool
      fastfetch # Neofetch but faster
      fd # Sexy find
      fzf # Fuzzy search tool
      gh # GitHub CLI
      gitui # TUI for git
      glow # CLI markdown renderer
      kubectl # Official kubernetes CLI
      k9s # Kubernetes cluster TUI
      lazygit # Another TUI for git
      ripgrep # Text search
      sd # Sexy sed
      starship # Prompt configuration
      unzip # Extraction utility
      xh # CLI Http Client
      xplr # TUI File Explorer
      zellij # Terminal Multiplexer
      zoxide # Directory Portal
    ];
  };
}
