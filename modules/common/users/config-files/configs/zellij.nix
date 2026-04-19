{
  lib,
  pkgs,
  ...
}: {
  # Zellij terminal multiplexer configuration
  mkZellijScript = {
    homeDir,
    enabled,
  }: let
    copyCommand =
      if pkgs.stdenv.isDarwin
      then ''copy_command "pbcopy"''
      else ''copy_command "wl-copy"'';
    zellijConfig = lib.replaceStrings ["{{COPY_COMMAND}}"] [copyCommand] (builtins.readFile ../files/zellij.kdl);
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
