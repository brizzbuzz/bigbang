{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # Generate 1Password SSH agent config for each user
  mk1PasswordConfig = userName: userConfig: let
    personalConfig = ''
      [[ssh-keys]]
      item = "Personal Auth Key"
      vault = "Private"
      account = "my.1password.com"

      [[ssh-keys]]
      item = "Personal Signing Key"
      vault = "Private"
      account = "my.1password.com"
    '';

    workConfig = ''
      [[ssh-keys]]
      item = "Odyssey Auth Key"
      vault = "Employee"
      account = "teamodyssey.1password.com"

      [[ssh-keys]]
      item = "Odyssey Signing Key"
      vault = "Employee"
      account = "teamodyssey.1password.com"
    '';
  in
    if userConfig.profile == "personal"
    then personalConfig
    else workConfig;

  # Generate Zed config for each user
  mkZedConfig = userName: userConfig: let
    baseConfig = {
      theme = "Catppuccin Macchiato";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "JetBrainsMono Nerd Font";
      autosave = "on_focus_change";
      tab_size = 2;
      hard_tabs = false;
      show_whitespaces = "selection";
      vim_mode = false;
      assistant = {
        enabled = true;
        version = "2";
      };
    };

    personalConfig =
      baseConfig
      // {
        assistant.provider.anthropic = {
          api_url = "https://api.anthropic.com";
          low_speed_timeout_in_seconds = 30;
        };
      };

    workConfig =
      baseConfig
      // {
        assistant.provider.anthropic = {
          api_url = "https://api.anthropic.com";
          low_speed_timeout_in_seconds = 30;
        };
      };
  in
    if userConfig.profile == "personal"
    then personalConfig
    else workConfig;

  # Generate SSH config for each user
  mkSSHConfig = userName: userConfig: ''
    Host *
      IdentityAgent ~/.1password/agent.sock
      AddKeysToAgent yes

    # Personal GitHub
    Host github.com
      Hostname github.com
      User git
      IdentitiesOnly yes

    # Homelab servers
    Host callisto.chateaubr.ink ganymede.chateaubr.ink
      User ryan
      IdentitiesOnly yes

    # Local network shorthand
    Host callisto
      Hostname callisto.chateaubr.ink
      User ryan

    Host ganymede
      Hostname ganymede.chateaubr.ink
      User ryan
  '';
in {
  options.host.userConfigs = {
    enable = lib.mkEnableOption "Enable user configuration file management";
  };

  config = lib.mkIf cfg.userConfigs.enable {
    # Deploy configuration files for each user via activation scripts
    system.activationScripts.userConfigFiles = {
      text = lib.concatMapStringsSep "\n" (userName: let
        userConfig = cfg.users.${userName};
        homeDir =
          if isDarwin
          then "/Users/${userName}"
          else "/home/${userName}";
        userGroup =
          if isDarwin
          then "staff"
          else userName;
      in ''
        # Create config directories
        mkdir -p ${homeDir}/.config/{1Password/ssh,zed,starship,zellij}
        mkdir -p ${homeDir}/.ssh

        # 1Password SSH agent configuration
        cat > ${homeDir}/.config/1Password/ssh/agent.toml << 'EOF'
        ${mk1PasswordConfig userName userConfig}
        EOF
        chmod 600 ${homeDir}/.config/1Password/ssh/agent.toml

        # Zed editor configuration
        cat > ${homeDir}/.config/zed/settings.json << 'EOF'
        ${builtins.toJSON (mkZedConfig userName userConfig)}
        EOF
        chmod 644 ${homeDir}/.config/zed/settings.json

        # SSH configuration
        cat > ${homeDir}/.ssh/config << 'EOF'
        ${mkSSHConfig userName userConfig}
        EOF
        chmod 600 ${homeDir}/.ssh/config

        # Starship configuration
        cat > ${homeDir}/.config/starship.toml << 'EOF'
        format = """
        $all$character
        """

        [character]
        success_symbol = "[➜](bold green)"
        error_symbol = "[➜](bold red)"

        [git_branch]
        symbol = "🌱 "

        [directory]
        truncation_length = 3
        truncate_to_repo = false

        [git_status]
        conflicted = "🏳"
        ahead = "🏎💨"
        behind = "😰"
        diverged = "😵"
        up_to_date = "✓"
        untracked = "🤷‍"
        stashed = "📦"
        modified = "📝"
        staged = "[++($count)](green)"
        renamed = "👅"
        deleted = "🗑"
        EOF
        chmod 644 ${homeDir}/.config/starship.toml

        # Zellij configuration
        cat > ${homeDir}/.config/zellij/config.kdl << 'EOF'
        theme "catppuccin-macchiato"
        default_shell "zsh"

        keybinds {
            normal {
                bind "Alt h" { MoveFocus "Left"; }
                bind "Alt l" { MoveFocus "Right"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }
            }
        }
        EOF
        chmod 644 ${homeDir}/.config/zellij/config.kdl

        # Set ownership (ignore errors if user doesn't exist yet)
        chown -R ${userName}:${userGroup} ${homeDir}/.config ${homeDir}/.ssh 2>/dev/null || true
      '') (lib.attrNames cfg.users);
    };
  };
}
