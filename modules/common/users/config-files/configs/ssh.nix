{
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  # SSH configuration with platform-specific 1Password agent path
  mkSshScript = {
    homeDir,
    enabled,
  }: let
    onePasswordAgentPath =
      if isDarwin
      then "\"${homeDir}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
      else "${homeDir}/.1password/agent.sock";

    sshConfig = ''
      Host *
        IdentityAgent ${onePasswordAgentPath}
        AddKeysToAgent yes

      # Personal GitHub
      Host github.com
        Hostname github.com
        User git

      # Homelab servers
      Host callisto.chateaubr.ink ganymede.chateaubr.ink
        User ryan

      # Local network shorthand
      Host callisto
        Hostname callisto.chateaubr.ink
        User ryan

      Host ganymede
        Hostname ganymede.chateaubr.ink
        User ryan
    '';
  in
    lib.optionalString enabled ''
        # SSH configuration
        [ -L "${homeDir}/.ssh/config" ] && rm "${homeDir}/.ssh/config"
        cat > "${homeDir}/.ssh/config" << 'EOFSSH'
      ${sshConfig}
      EOFSSH
        chmod 600 "${homeDir}/.ssh/config"
    '';
}
