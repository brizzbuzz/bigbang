{
  lib,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  nushellConfig = builtins.readFile ../files/nushell/config.nu;
  nushellEnv = builtins.readFile ../files/nushell/env.nu;
  nushellAutoloadDir = ../files/nushell/autoload;
  nushellAutoloadFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nu" name) (builtins.readDir nushellAutoloadDir);
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
        [ -L "${nushellConfigDir}/autoload" ] && rm "${nushellConfigDir}/autoload"
        mkdir -p "${nushellConfigDir}"
        mkdir -p "${nushellConfigDir}/autoload"

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

      ${lib.concatMapStringsSep "\n" (
        fileName: let
          fileContents = builtins.readFile (nushellAutoloadDir + "/${fileName}");
        in ''
            [ -L "${nushellConfigDir}/autoload/${fileName}" ] && rm "${nushellConfigDir}/autoload/${fileName}"
            cat > "${nushellConfigDir}/autoload/${fileName}" << 'EOFNUAUTOLOAD_${lib.toUpper (lib.replaceStrings ["."] ["_"] fileName)}'
          ${fileContents}
          EOFNUAUTOLOAD_${lib.toUpper (lib.replaceStrings ["."] ["_"] fileName)}
            chmod 644 "${nushellConfigDir}/autoload/${fileName}"
        ''
      ) (builtins.attrNames nushellAutoloadFiles)}

        ${lib.optionalString isDarwin ''
        chown -R "${userName}:${userGroup}" "${nushellConfigDir}" 2>/dev/null || true
      ''}
    '';
}
