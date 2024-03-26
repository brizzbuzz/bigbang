{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home = {
    packages =
      (with pkgs; [
        atuin # Magical Shell History
        bat # Sexy cat
        bottom # TUI System Monitoring
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
        lf # File Manager
        mods # AI on the CL
        nnn # Terminal File Browser
        ripgrep # Text search
        sd # Sexy sed
        spotify-tui # TUI for Spotify (Required to control spotifyd)
        starship # Prompt configuration
        tokei # Code line counter
        unzip # Extraction utility
        xplr # TUI File Explorer
        zellij # Terminal Multiplexer
      ])
      ++ (with pkgs-unstable; [
        alacritty # Terminal Emulator
        mise # Tool version manager
        wallust # Color theme utility
        zoxide # Directory Portal
      ]);
  };
}
