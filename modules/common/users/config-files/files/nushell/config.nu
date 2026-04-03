# Nushell Config File
$env.config.show_banner = false

# Environment variables
$env.EDITOR = "hx"
$env.config.buffer_editor = $env.EDITOR
$env.ZELLIJ_CONFIG_DIR = ($env.HOME | path join ".config" "zellij")

alias oc = opencode
alias lg = lazygit
alias zj = zellij

if $nu.os-info.name == "linux" and not (which command-not-found | is-empty) {
  $env.config.hooks.command_not_found = {|command_name|
    command-not-found $command_name | str trim
  }
}
