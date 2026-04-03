# Atuin integration.

module compat {
    export def --wrapped "random uuid -v 7" [...rest] { atuin uuid }
}

use (if not ((version).major > 0 or (version).minor >= 103) { "compat" }) *

$env.ATUIN_SESSION = (random uuid -v 7 | str replace -a "-" "")
hide-env -i ATUIN_HISTORY_ID

let atuin_keybinding_token = $"# (random uuid)"

let atuin_pre_execution = {||
    if ($nu | get history-enabled?) == false {
        return
    }

    let command = (commandline)
    if ($command | is-empty) {
        return
    }

    if not ($command | str starts-with $atuin_keybinding_token) {
        $env.ATUIN_HISTORY_ID = (atuin history start -- $command)
    }
}

let atuin_pre_prompt = {||
    let last_exit = $env.LAST_EXIT_CODE
    if 'ATUIN_HISTORY_ID' not-in $env {
        return
    }

    with-env { ATUIN_LOG: error } {
        if (version).minor >= 104 or (version).major > 0 {
            job spawn -t atuin {
                ^atuin history end $'--exit=($env.LAST_EXIT_CODE)' -- $env.ATUIN_HISTORY_ID | complete
            } | ignore
        } else {
            do { atuin history end $'--exit=($last_exit)' -- $env.ATUIN_HISTORY_ID } | complete
        }
    }

    hide-env ATUIN_HISTORY_ID
}

def atuin_search_cmd [...flags: string] {
    if (version).minor >= 106 or (version).major > 0 {
        [
            $atuin_keybinding_token
            ([
                `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline), ATUIN_SHELL: nu } {`
                ([
                    'let output = (run-external atuin search'
                    ($flags | append [--interactive] | each {|flag| $'"($flag)"' })
                    'e>| str trim)'
                ] | flatten | str join ' ')
                'if ($output | str starts-with "__atuin_accept__:") {'
                'commandline edit --accept ($output | str replace "__atuin_accept__:" "")'
                '} else {'
                'commandline edit $output'
                '}'
                `}`
            ] | flatten | str join "\n")
        ]
    } else {
        [
            $atuin_keybinding_token
            ([
                `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`
                'commandline edit'
                '(run-external atuin search'
                ($flags | append [--interactive] | each {|flag| $'"($flag)"' })
                ' e>| str trim)'
                `}`
            ] | flatten | str join ' ')
        ]
    } | str join "\n"
}

$env.config.hooks.pre_execution = ($env.config.hooks.pre_execution? | default [] | append $atuin_pre_execution)
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt? | default [] | append $atuin_pre_prompt)

$env.config.keybindings = ($env.config.keybindings? | default [] | append {
    name: atuin
    modifier: control
    keycode: char_r
    mode: [emacs vi_normal vi_insert]
    event: { send: executehostcommand cmd: (atuin_search_cmd) }
})

$env.config.keybindings = ($env.config.keybindings | append {
    name: atuin
    modifier: none
    keycode: up
    mode: [emacs vi_normal vi_insert]
    event: {
        until: [
            { send: menuup }
            { send: executehostcommand cmd: (atuin_search_cmd '--shell-up-key-binding') }
        ]
    }
})
