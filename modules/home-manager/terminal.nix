{
  pkgs,
  # pkgs-unstable,
  ...
}: {
  home = {
    packages =
      (with pkgs; [
        bat # Sexy cat
        colmena # Stateless Nixos Deployment tool
        bottom # TUI System Monitoring
        dive # Docker image explorer
        doggo # DNS lookup tool
        du-dust # TUI folder size tool
        dua # TUI disk space tool
        espanso # Text Expander
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
        # slurp # Screenshot utility
        starship # Prompt configuration
        sysz # Systemctl TUI
        tokei # Code line counter
        unzip # Extraction utility
        xplr # TUI File Explorer
        zellij # Terminal Multiplexer
      ])
      # TODO: Add back unstable once darwin bug resolved
      # TODO: Add darwin/nix specific packages
      # ++ (with pkgs-unstable; [
      ++ (with pkgs; [
        alacritty # Terminal Emulator
        atuin # Magical Shell History
        lazysql # Database TUI
        mise # Tool version manager
        # wallust # Color theme utility
        # wf-recorder # Wayland screen recorder
        # NOTE: Can't get this one to work
        # wl-screenrec # Another wayland screen recorder
        zoxide # Directory Portal
      ]);
  };

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
