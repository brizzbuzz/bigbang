{lib, ...}: {
  # Starship prompt configuration
  mkStarshipScript = {
    homeDir,
    enabled,
  }: let
    starshipConfig = builtins.readFile ../files/starship.toml;
  in
    lib.optionalString enabled ''
        # Starship configuration
        [ -L "${homeDir}/.config/starship.toml" ] && rm "${homeDir}/.config/starship.toml"
        cat > "${homeDir}/.config/starship.toml" << 'EOFSTARSHIP'
      ${starshipConfig}
      EOFSTARSHIP
        chmod 644 "${homeDir}/.config/starship.toml"
    '';
}
