{
  lib,
  pkgs,
  ...
}: let
  opencodeConfigTemplate = builtins.readFile ../files/opencode.jsonc.template;
in {
  mkOpencodeScript = {
    user,
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

        USER_PROFILE="${user.profile}"
        if [ "$USER_PROFILE" = "work" ]; then
          DATADOG_MCP_ENABLED="true"
          DATADOG_MCP_CLI_PATH="${pkgs.datadog-mcp-cli}/bin/datadog_mcp_cli"
        else
          DATADOG_MCP_ENABLED="false"
          DATADOG_MCP_CLI_PATH="/usr/bin/false"
        fi

        cat > "${homeDir}/.config/opencode/opencode.jsonc" << 'EOFOPENCODE'
      ${opencodeConfigTemplate}
      EOFOPENCODE

        # Replace placeholders with actual values using pure shell (no sed needed)
        temp_file="${homeDir}/.config/opencode/opencode.jsonc.tmp"
        while IFS= read -r line; do
          line="''${line//\{\{KAGI_API_KEY_PLACEHOLDER_REPLACE_AT_BUILD_TIME\}\}/$KAGI_KEY}"
          line="''${line//\{\{DATADOG_MCP_CLI_PATH\}\}/$DATADOG_MCP_CLI_PATH}"
          line="''${line//\{\{DATADOG_MCP_ENABLED\}\}/$DATADOG_MCP_ENABLED}"
          echo "$line"
        done < "${homeDir}/.config/opencode/opencode.jsonc" > "$temp_file"
        mv "$temp_file" "${homeDir}/.config/opencode/opencode.jsonc"
        chmod 644 "${homeDir}/.config/opencode/opencode.jsonc"
    '';
}
