{lib, ...}: {
  # Direnv configuration
  mkDirenvScript = {
    homeDir,
    enabled,
  }: let
    direnvConfig = builtins.readFile ../files/direnv.toml;
  in
    lib.optionalString enabled ''
        # Direnv configuration
        mkdir -p "${homeDir}/.config/direnv"

        # Remove old home-manager symlink if it exists
        [ -L "${homeDir}/.config/direnv/direnv.toml" ] && rm "${homeDir}/.config/direnv/direnv.toml"

        cat > "${homeDir}/.config/direnv/direnv.toml" << 'EOFDIRENV'
      ${direnvConfig}
      EOFDIRENV
        chmod 644 "${homeDir}/.config/direnv/direnv.toml"
    '';
}
