{
  lib,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
  # Default Zed configuration that both profiles share
  baseZedConfig = {
    icon_theme = "Zed (Default)";
    gutter = {
      line_numbers = true;
    };
    load_direnv = "direct";
    terminal = {
      shell = {
        program = "nu";
      };
    };
    agent = {
      default_profile = "write";
      always_allow_tool_actions = false;
      default_model = {
        provider = "zed.dev";
        model = "claude-sonnet-4";
      };
    };

    features = {
      edit_prediction_provider = "zed";
    };
    vim_mode = true;
    base_keymap = "JetBrains";
    ui_font_size = 14;
    buffer_font_size = 12;
    theme = {
      mode = "system";
      light = "Ayu Light";
      dark = "One Dark";
    };
    languages = {
      Nix = {
        formatter = {
          external = {
            command = "alejandra";
          };
        };
      };
    };
  };

  # Work profile configuration with Anthropic provider
  workZedConfig =
    baseZedConfig
    // {
      agent =
        baseZedConfig.agent
        // {
          default_model = {
            provider = "anthropic";
            model = "claude-sonnet-4-latest";
          };
        };
    };

  # Context server definitions
  contextServers = {
    linear = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "https://mcp.linear.app/sse"];
    };

    figma = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "http://127.0.0.1:3845/mcp"];
    };

    asana = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "https://mcp.asana.com/sse"];
    };

    nixos = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#nixos" "-c" "nixos-rebuild" "switch" "--flake" "github:utensils/mcp-nixos/v1.0.0"];
    };

    gitbutler = {
      source = "custom";
      command = "but";
      args = ["mcp"];
    };

    browsermcp = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "@browsermcp/mcp@latest"];
    };

    playwright = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "@playwright/mcp@latest"];
    };

    notion = {
      source = "custom";
      command = "nix";
      args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "https://mcp.notion.com/mcp"];
    };
  };

  # Function to create Zed config with specific context servers
  mkZedConfig = servers: let
    config =
      baseZedConfig
      // {
        context_servers = lib.genAttrs servers (name: contextServers.${name});
      };
  in
    jsonFormat.generate "zed-settings.json" config;

  # Function to create work Zed config with specific context servers
  mkWorkZedConfig = servers: let
    config =
      workZedConfig
      // {
        context_servers = lib.genAttrs servers (name: contextServers.${name});
      };
  in
    jsonFormat.generate "zed-settings.json" config;
in {
  # Export the configuration functions
  zed = {
    inherit mkZedConfig mkWorkZedConfig contextServers baseZedConfig workZedConfig;

    # Pre-configured profiles
    personal = mkZedConfig ["linear" "nixos" "gitbutler" "browsermcp" "figma" "playwright"];
    work = mkWorkZedConfig ["linear" "asana" "figma" "nixos" "gitbutler" "browsermcp" "playwright" "notion"];
  };
}
