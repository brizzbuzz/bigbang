# Zoxide integration.

# Jump to a directory using zoxide ranking.
def --env --wrapped __zoxide_z [...rest: string] {
    if (which zoxide | is-empty) {
        print -e "Error: zoxide not found in PATH"
        return
    }

    let path = match $rest {
        [] => { '~' }
        ['-'] => { '-' }
        [$arg] if ($arg | path expand | path type) == 'dir' => { $arg }
        _ => {
            zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
        }
    }

    cd $path
}

 # Jump to a directory using zoxide's interactive selector.
def --env --wrapped __zoxide_zi [...rest: string] {
    if (which zoxide | is-empty) {
        print -e "Error: zoxide not found in PATH"
        return
    }

    cd $'(zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}

alias z = __zoxide_z
alias zi = __zoxide_zi

if not (which zoxide | is-empty) {
    $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default [])

    let zoxide_hooked = (
        $env.config.hooks.env_change.PWD
        | any {|hook| try { $hook.__zoxide_hook? == true } catch { false } }
    )

    if not $zoxide_hooked {
        $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
            __zoxide_hook: true
            code: {|_, dir|
                if not (which zoxide | is-empty) {
                    zoxide add -- $dir
                }
            }
        })
    }
}
