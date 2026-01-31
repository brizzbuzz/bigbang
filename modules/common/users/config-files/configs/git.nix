{lib, ...}: let
  # Git configuration with profile-based defaults
  profileDefaults = {
    personal = {
      name = "Ryan Brink";
      email = "dev@ryanbr.ink";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+4LZpJ9+QmvjLKMzmHX1aUdsnoOlrrcTjwKhcwnCN1";
    };
    work = {
      name = "Ryan Brink";
      email = "ryan@withodyssey.com";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvZU9QjyJpanD7LGnSn4e5gcOdLqL8nkUYfowWyrFvl";
    };
  };

  # Resolve git config for a user (profile defaults + per-user overrides)
  getGitConfig = user: let
    defaults = profileDefaults.${user.profile};
  in {
    name =
      if user.git.name != null
      then user.git.name
      else defaults.name;
    email =
      if user.git.email != null
      then user.git.email
      else defaults.email;
    signingKey =
      if user.git.signingKey != null
      then user.git.signingKey
      else defaults.signingKey;
  };

  # Generate git config content
  mkGitConfig = gitSettings: ''
    [user]
      name = ${gitSettings.name}
      email = ${gitSettings.email}
      signingKey = ${gitSettings.signingKey}
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
  '';
in {
  mkGitScript = {
    user,
    homeDir,
    enabled,
  }: let
    gitConfig = getGitConfig user;
  in
    lib.optionalString enabled ''
        # Git configuration
        [ -L "${homeDir}/.gitconfig" ] && rm "${homeDir}/.gitconfig"
        cat > "${homeDir}/.gitconfig" << 'EOFGIT'
      ${mkGitConfig gitConfig}
      EOFGIT
        chmod 644 "${homeDir}/.gitconfig"
    '';
}
