{
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  nushellConfig = builtins.readFile ../files/nushell/config.nu;
  nushellEnv = builtins.readFile ../files/nushell/env.nu;
in {
  mkNushellScript = {
    userName,
    homeDir,
    userGroup,
    enabled,
  }: let
    # Nushell config location differs by platform
    nushellConfigDir =
      if isDarwin
      then "${homeDir}/Library/Application Support/nushell"
      else "${homeDir}/.config/nushell";
  in
    lib.optionalString enabled ''
        # Nushell configuration
        mkdir -p "${nushellConfigDir}"

        # Remove old symlinks if they exist (from home-manager)
        [ -L "${nushellConfigDir}/config.nu" ] && rm "${nushellConfigDir}/config.nu"
        [ -L "${nushellConfigDir}/env.nu" ] && rm "${nushellConfigDir}/env.nu"

        cat > "${nushellConfigDir}/config.nu" << 'EOFNUCONFIG'
      ${nushellConfig}
      EOFNUCONFIG
        chmod 644 "${nushellConfigDir}/config.nu"

        cat > "${nushellConfigDir}/env.nu" << 'EOFNUENV'
      ${nushellEnv}
      EOFNUENV
        chmod 644 "${nushellConfigDir}/env.nu"

        ${lib.optionalString isDarwin ''
        chown -R "${userName}:${userGroup}" "${nushellConfigDir}" 2>/dev/null || true
      ''}
    '';
}
