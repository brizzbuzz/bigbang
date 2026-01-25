# Nushell Environment Config File
$env.STARSHIP_SHELL = "nu"

# 1Password SSH Agent
$env.SSH_AUTH_SOCK = $"($env.HOME)/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

def create_left_prompt [] {
  starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "
