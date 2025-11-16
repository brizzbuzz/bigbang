{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host;
  isDarwin = pkgs.stdenv.isDarwin;

  # Get git settings for each user based on their profile
  getUserGitConfig = userConfig: let
    personalConfig = {
      user = {
        name = "Ryan Brink";
        email = "dev@ryanbr.ink";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
      };
    };

    workConfig = {
      user = {
        name = "Ryan Brink";
        email = "ryan@withodyssey.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvZU9QjyJpanD7LGnSn4e5gcOdLqL8nkUYfowWyrFvl";
      };
    };
  in
    if userConfig.profile == "personal"
    then personalConfig
    else workConfig;
in {
  options.host.userGit = {
    enable = lib.mkEnableOption "Enable user-specific git configuration";
  };

  config = lib.mkIf cfg.userGit.enable {
    # Global git configuration - disabled for now to fix build
    # programs.git = lib.mkIf isLinux {
    #   enable = true;
    #   config = {
    #     init.defaultBranch = "main";
    #     pull.rebase = true;
    #     push.autoSetupRemote = true;
    #     commit.gpgSign = true;
    #     gpg.format = "ssh";
    #     core.editor = "nano";
    #   };
    # };

    # User-specific git configuration files via activation script
    system.activationScripts.userGitConfigs = {
      text = lib.concatMapStringsSep "\n" (userName: let
        userConfig = cfg.users.${userName};
        gitConfig = getUserGitConfig userConfig;
        homeDir =
          if isDarwin
          then "/Users/${userName}"
          else "/home/${userName}";
      in ''
                mkdir -p ${homeDir}
                cat > ${homeDir}/.gitconfig-user << 'EOF'
        [user]
          name = ${gitConfig.user.name}
          email = ${gitConfig.user.email}
          signingKey = ${gitConfig.user.signingKey}
        [init]
          defaultBranch = main
        [pull]
          rebase = true
        [push]
          autoSetupRemote = true
        [commit]
          gpgSign = true
        [gpg]
          format = ssh
        [core]
          editor = nano
        EOF
                chown ${userName}:${
          if isDarwin
          then "staff"
          else userName
        } ${homeDir}/.gitconfig-user 2>/dev/null || true
      '') (lib.attrNames cfg.users);
    };

    # Git package
    environment.systemPackages = with pkgs; [
      git
      gh
    ];
  };
}
