# Nushell Environment Config File

# Set up PATH first, before anything else
if ("/opt/homebrew/bin" | path exists) {
  $env.PATH = ($env.PATH | split row (char esep) | prepend "/opt/homebrew/bin")
}
if ("/usr/local/bin" | path exists) {
  $env.PATH = ($env.PATH | split row (char esep) | prepend "/usr/local/bin")
}
$env.PATH = ($env.PATH | split row (char esep) | prepend "/run/current-system/sw/bin")
$env.PATH = ($env.PATH | split row (char esep) | prepend "/run/wrappers/bin")

let path_entries = ($env.PATH | split row (char esep))
if ("/run/wrappers/bin" | path exists) {
  if ($path_entries | first) != "/run/wrappers/bin" {
    print -e "Warning: /run/wrappers/bin is not first in PATH"
  }
}

$env.STARSHIP_SHELL = "nu"

# 1Password SSH Agent
$env.SSH_AUTH_SOCK = $"($env.HOME)/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

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
