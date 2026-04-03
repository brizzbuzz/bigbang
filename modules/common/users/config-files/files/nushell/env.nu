# Nushell Environment Config File

use std/util "path add"

# Set up PATH first, before anything else
if ("/opt/homebrew/bin" | path exists) {
  path add "/opt/homebrew/bin"
}
if ("/usr/local/bin" | path exists) {
  path add "/usr/local/bin"
}
path add "/run/current-system/sw/bin"
path add "/run/wrappers/bin"

if ("/run/wrappers/bin" | path exists) {
  if ($env.PATH | first) != "/run/wrappers/bin" {
    print -e "Warning: /run/wrappers/bin is not first in PATH"
  }
}

$env.STARSHIP_SHELL = "nu"

# 1Password SSH Agent
if $nu.os-info.name == "macos" {
  let onepassword_ssh_sock = ($env.HOME | path join "Library" "Group Containers" "2BUA8C4S2C.com.1password" "t" "agent.sock")

  if ($onepassword_ssh_sock | path exists) {
    $env.SSH_AUTH_SOCK = $onepassword_ssh_sock
  }
}

def create_left_prompt [] {
  if (which starship | is-empty) {
    print -e "Warning: starship not found in PATH"
    return "> "
  }
  starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "
