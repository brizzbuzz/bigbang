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
      version = "2";
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

  # Context server definitions
  contextServers = {
    source = "custom";
    linear = {
      command = {
        path = "nix";
        args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "https://mcp.linear.app/sse"];
        env = {};
      };
      settings = {};
    };

    figma = {
      source = "custom";
      command = {
        path = "nix";
        args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "http://127.0.0.1:3845/sse"];
        env = {};
      };
      settings = {};
    };

    asana = {
      source = "custom";
      command = {
        path = "nix";
        args = ["shell" "nixpkgs#pnpm" "-c" "pnpm" "dlx" "mcp-remote" "https://mcp.asana.com/sse"];
        env = {};
      };
      settings = {};
    };

    nixos = {
      source = "custom";
      command = {
        path = "nix";
        args = ["run" "github:utensils/mcp-nixos/v1.0.0" "--"];
        env = {};
      };
      settings = {};
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
in {
  # Export the configuration functions
  zed = {
    inherit mkZedConfig contextServers baseZedConfig;

    # Pre-configured profiles
    personal = mkZedConfig ["linear" "nixos"];
    work = mkZedConfig ["linear" "asana" "figma" "nixos"];
  };
}
