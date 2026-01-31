{lib, ...}: {
  # Zellij terminal multiplexer configuration
  mkZellijScript = {
    homeDir,
    enabled,
  }: let
    zellijConfig = builtins.readFile ../files/zellij.kdl;
  in
    lib.optionalString enabled ''
        # Zellij configuration
        [ -L "${homeDir}/.config/zellij/config.kdl" ] && rm "${homeDir}/.config/zellij/config.kdl"
        cat > "${homeDir}/.config/zellij/config.kdl" << 'EOFZELLIJ'
      ${zellijConfig}
      EOFZELLIJ
        chmod 644 "${homeDir}/.config/zellij/config.kdl"
    '';
}
