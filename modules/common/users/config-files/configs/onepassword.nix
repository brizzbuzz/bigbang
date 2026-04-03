{lib, ...}: let
  onePasswordAgent = builtins.readFile ../files/1password-agent.toml;
in {
  mkOnePasswordScript = {
    homeDir,
    enabled,
  }:
    lib.optionalString enabled ''
        # 1Password SSH agent configuration
        [ -L "${homeDir}/.config/1Password/ssh/agent.toml" ] && rm "${homeDir}/.config/1Password/ssh/agent.toml"
        cat > "${homeDir}/.config/1Password/ssh/agent.toml" << 'EOFONEPASSWORD'
      ${onePasswordAgent}
      EOFONEPASSWORD
        chmod 600 "${homeDir}/.config/1Password/ssh/agent.toml"
    '';
}
