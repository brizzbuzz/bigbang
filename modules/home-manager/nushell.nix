{pkgs, ...}: let
  isDarwin = pkgs.stdenv.isDarwin;
  rebuildCommand =
    if isDarwin
    then "sudo darwin-rebuild switch --flake .#"
    else "sudo colmena apply-local --impure";
  rebuildRemoteCommand =
    if isDarwin
    then "colmena apply --impure --on"
    else "sudo colmena apply --impure --on";
in {
  programs.nushell = {
    enable = true;

    configFile.text = ''
      $env.config = {
        show_banner: false,
      }

      # Environment variables
      $env.EDITOR = "nvim"

      # Path
      $env.PATH = ($env.PATH | split row (char esep) | prepend "/usr/local/bin")
      $env.PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin') # TODO: Only if on macOS

      # Helper function to get file info
      def get_file_info [path: string] {
          let mime = (^${pkgs.file}/bin/file --mime-type $path | str trim)
          let size = (ls $path | get size | first | into int)
          let is_text = ($mime | str contains "text/") or ([
              "application/json"
              "application/javascript"
              "application/x-ruby"
              "application/xml"
              "application/x-php"
              "application/x-yaml"
              "application/toml"
              "application/x-sh"
              "application/x-shellscript"
          ] | any {|fmt| $mime | str contains $fmt})

          {
              mime: $mime,
              size: $size,
              is_text: $is_text
          }
      }

      # Helper function to format file size
      def format_file_size [size: int] {
          if $size < 1024 {
              $"($size)B"
          } else if $size < (1024 * 1024) {
              $"(($size / 1024 | into float | math round -p 2))KB"
          } else if $size < (1024 * 1024 * 1024) {
              $"(($size / 1024 / 1024 | into float | math round -p 2))MB"
          } else {
              $"(($size / 1024 / 1024 / 1024 | into float | math round -p 2))GB"
          }
      }

      # Helper function to copy to clipboard based on OS
      def copy_to_clipboard [content: string] {
          if $nu.os-info.name == "macos" {
              $content | pbcopy
          } else if $nu.os-info.name == "linux" {
              $content | ^${pkgs.wl-clipboard}/bin/wl-copy
          } else {
              print "Clipboard operation not supported on this OS"
              return
          }
      }

      # Repository dump command
      def "repo dump" [
          output?: string = "repo_dump.txt"  # Optional output file name
          --include: string = "",            # Additional files to include pattern
          --exclude: string = "",            # Files to exclude pattern
          --copy(-c)                         # Copy to clipboard
      ] {
          let files = (^${pkgs.ripgrep}/bin/rg --files | lines | where {|path|
              let include_match = if $include == "" { true } else { $path | str contains $include }
              let is_git = ($path | str contains "/.git/")
              let is_excluded = if $exclude == "" {
                  false
              } else {
                  $path | str contains $exclude
              }
              $include_match and (not $is_git) and (not $is_excluded)
          })

          # Process each file and collect content
          let content = ($files | each {|file|
              let info = (get_file_info $file)
              let size_str = (format_file_size $info.size)

              # Create file header with type and size info
              let header = if $info.is_text {
                  $"--- .($file) [($size_str)]"
              } else {
                  $"--- .($file) [($size_str)] [BINARY: ($info.mime)]"
              }

              # Return this file's content
              if $info.is_text {
                  [$"(char newline)($header)(char newline)" (open $file --raw) (char newline)]
              } else {
                  [$"(char newline)($header)(char newline)"]
              }
          } | flatten | str join "")

          # Handle output - can do both file and clipboard if requested
          if $copy {
              copy_to_clipboard $content
              print "Repository content copied to clipboard!"
          }

          # Always save to file if output is provided
          if not ($output == null) {
              $content | save --force $output
              print $"Content saved to ($output)"
          }

          # Return the output path if we saved to a file
          if not ($output == null) {
              $output
          }
      }
    '';

    extraConfig = ''
      # Aliases
      alias nr = ${rebuildCommand}
      alias nrr = ${rebuildRemoteCommand}
      alias rd = repo dump
      alias zj = zellij
    '';

    envFile.text = ''
      # Nushell Environment Config File
      $env.STARSHIP_SHELL = "nu"

      def create_left_prompt [] {
        starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }

      $env.PROMPT_COMMAND = { create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""
      $env.PROMPT_INDICATOR = "❯"
      $env.PROMPT_INDICATOR_VI_INSERT = ": "
      $env.PROMPT_INDICATOR_VI_NORMAL = "❯"
      $env.PROMPT_MULTILINE_INDICATOR = "::: "
    '';
  };
}
