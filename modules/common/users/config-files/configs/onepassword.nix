{lib, ...}: let
  onePasswordPersonal = builtins.readFile ../files/1password-agent-personal.toml;
  onePasswordWork = builtins.readFile ../files/1password-agent-work.toml;

  # Get 1Password config based on profile
  get1PasswordConfig = user:
    if user.profile == "personal"
    then onePasswordPersonal
    else onePasswordWork;
in {
  mkOnePasswordScript = {
    user,
    homeDir,
    enabled,
  }:
    lib.optionalString enabled ''
        # 1Password SSH agent configuration
        [ -L "${homeDir}/.config/1Password/ssh/agent.toml" ] && rm "${homeDir}/.config/1Password/ssh/agent.toml"
        cat > "${homeDir}/.config/1Password/ssh/agent.toml" << 'EOFONEPASSWORD'
      ${get1PasswordConfig user}
      EOFONEPASSWORD
        chmod 600 "${homeDir}/.config/1Password/ssh/agent.toml"
    '';
}
