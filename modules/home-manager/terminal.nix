{pkgs, ...}: {
  home = {
    packages =
      (with pkgs; [
        codex # OpenAI Codex CLI
        colmena # Stateless Nixos Deployment tool
        crush # Crush AI CLI
        dive # Docker image explorer
        doggo # DNS lookup tool
        dust # TUI folder size tool
        dua # TUI disk space tool
        erdtree # File tree
        fastfetch # Neofetch but faster
        fd # Sexy find
        fzf # Fuzzy search tool
        gemini-cli # Gemini AI CLI
        gh # GitHub CLI
        glow # CLI markdown renderer
        gnupg # GPG CLI
        kubectl # Official kubernetes CLI
        k9s # Kubernetes cluster TUI
        lazygit # Another TUI for git
        lf # File Manager
        mods # AI on the CL
        nnn # Terminal File Browser
        ripgrep # Text search
        sd # Sexy sed
        sysz # Systemctl TUI
        tokei # Code line counter
        unzip # Extraction utility
        uv # Python Package Manager
        xplr # TUI File Explorer
        lazysql # Database TUI
        yubikey-manager # Yubikey CLI
      ])
      ++ (
        if !pkgs.stdenv.isDarwin
        then
          with pkgs; [
            distrobox # Container manager
            playerctl # Media player TUI
          ]
        else []
      );
  };
}
