{lib, ...}: let
  opencodeConfigTemplate = builtins.readFile ../files/opencode.jsonc.template;
in {
  mkOpencodeScript = {
    homeDir,
    enabled,
  }:
    lib.optionalString enabled ''
        # OpenCode configuration with Kagi API key injection
        [ -L "${homeDir}/.config/opencode/opencode.jsonc" ] && rm "${homeDir}/.config/opencode/opencode.jsonc"

        # Substitute Kagi API key from opnix secret
        KAGI_KEY_PATH="/var/lib/opnix/secrets/kagi-api-key"
        if [ -f "$KAGI_KEY_PATH" ]; then
          KAGI_KEY=$(cat "$KAGI_KEY_PATH")
        else
          KAGI_KEY="PLACEHOLDER_SECRET_NOT_AVAILABLE_CHECK_OPNIX_DEPLOYMENT"
        fi

        cat > "${homeDir}/.config/opencode/opencode.jsonc" << 'EOFOPENCODE'
      ${opencodeConfigTemplate}
      EOFOPENCODE

        # Replace placeholder with actual key (BSD sed for macOS)
        sed -i "" "s|{{KAGI_API_KEY_PLACEHOLDER_REPLACE_AT_BUILD_TIME}}|$KAGI_KEY|g" "${homeDir}/.config/opencode/opencode.jsonc"
        chmod 644 "${homeDir}/.config/opencode/opencode.jsonc"
    '';
}
