{
  lib,
  pkgs,
  ...
}: let
  opencodeAgentsPath = ../files/opencode/AGENTS.md;
  isDarwin = pkgs.stdenv.isDarwin;
  opencodeCommandsPath = ../files/opencode/commands;
  opencodeSkillsPath = ../files/opencode/skills;

  mkOpencodeConfig = {
    user,
    homeDir,
  }: let
    isWorkProfile = user.profile == "work";
    isRyan = user.name == "ryan";
    pencilEnabled = isDarwin && isRyan && !isWorkProfile;
    datadogCommand =
      if isWorkProfile
      then ["${pkgs.datadog-mcp-cli}/bin/datadog_mcp_cli"]
      else ["/usr/bin/false"];
  in {
    "$schema" = "https://opencode.ai/config.json";
    model = "openai/gpt-5.4";
    small_model = "openai/gpt-5.3-codex-spark";
    autoupdate = true;
    permission = {
      websearch = "deny";
      skill = {
        "*" = "allow";
      };
      external_directory = {
        "~/Workspace/**" = "allow";
      };
    };
    mcp = {
      chrome_devtools = {
        type = "local";
        command = ["npx" "chrome-devtools-mcp@latest"];
        enabled = true;
      };
      nixos = {
        type = "local";
        command = ["uvx" "mcp-nixos"];
        enabled = true;
      };
      nushell = {
        type = "local";
        command = ["nu" "--mcp"];
        enabled = true;
      };
      datadog = {
        type = "local";
        command = datadogCommand;
        enabled = isWorkProfile;
        environment = {};
      };
      pencil = {
        type = "local";
        command = [
          "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64"
          "--app"
          "desktop"
        ];
        enabled = pencilEnabled;
      };
      linear = {
        type = "remote";
        url = "https://mcp.linear.app/mcp";
      };
      notion = {
        type = "remote";
        url = "https://mcp.notion.com/mcp";
        enabled = isWorkProfile;
      };
      kagi = {
        type = "local";
        command = ["uvx" "kagimcp"];
        environment = {
          KAGI_API_KEY = "{file:${homeDir}/.config/opencode/secrets/kagi-api-key}";
        };
      };
    };
  };

  mkOpencodeTuiConfig = {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "opencode";
    scroll_acceleration = {
      enabled = true;
    };
  };
in {
  mkOpencodeScript = {
    user,
    homeDir,
    enabled,
  }: let
    opencodeConfigFile = (pkgs.formats.json {}).generate "opencode.json" (
      mkOpencodeConfig {
        inherit user homeDir;
      }
    );
    opencodeTuiConfigFile = (pkgs.formats.json {}).generate "tui.json" mkOpencodeTuiConfig;
  in
    lib.optionalString enabled ''
      [ -L "${homeDir}/.config/opencode/opencode.json" ] && rm "${homeDir}/.config/opencode/opencode.json"
      [ -L "${homeDir}/.config/opencode/opencode.jsonc" ] && rm "${homeDir}/.config/opencode/opencode.jsonc"
      [ -L "${homeDir}/.config/opencode/tui.json" ] && rm "${homeDir}/.config/opencode/tui.json"
      [ -L "${homeDir}/.config/opencode/tui.jsonc" ] && rm "${homeDir}/.config/opencode/tui.jsonc"
      rm -rf "${homeDir}/.config/opencode/secrets"
      rm -rf "${homeDir}/.config/opencode/commands" "${homeDir}/.config/opencode/skills"
      mkdir -p "${homeDir}/.config/opencode/commands" "${homeDir}/.config/opencode/skills" "${homeDir}/.config/opencode/secrets"

      if [ -f "/var/lib/opnix/secrets/kagi-api-key" ]; then
        cp "/var/lib/opnix/secrets/kagi-api-key" "${homeDir}/.config/opencode/secrets/kagi-api-key"
      else
        printf '%s\n' 'PLACEHOLDER_SECRET_NOT_AVAILABLE_CHECK_OPNIX_DEPLOYMENT' > "${homeDir}/.config/opencode/secrets/kagi-api-key"
      fi

      cp ${opencodeConfigFile} "${homeDir}/.config/opencode/opencode.json"
      cp ${opencodeConfigFile} "${homeDir}/.config/opencode/opencode.jsonc"
      cp ${opencodeTuiConfigFile} "${homeDir}/.config/opencode/tui.json"
      cp ${opencodeTuiConfigFile} "${homeDir}/.config/opencode/tui.jsonc"

      chmod 644 "${homeDir}/.config/opencode/opencode.json"
      chmod 644 "${homeDir}/.config/opencode/opencode.jsonc"
      chmod 644 "${homeDir}/.config/opencode/tui.json"
      chmod 644 "${homeDir}/.config/opencode/tui.jsonc"
      chmod 700 "${homeDir}/.config/opencode/secrets"
      chmod 600 "${homeDir}/.config/opencode/secrets/kagi-api-key"

      cp ${opencodeAgentsPath} "${homeDir}/.config/opencode/AGENTS.md"
      cp -R ${opencodeCommandsPath}/. "${homeDir}/.config/opencode/commands"
      cp -R ${opencodeSkillsPath}/. "${homeDir}/.config/opencode/skills"
    '';
}
