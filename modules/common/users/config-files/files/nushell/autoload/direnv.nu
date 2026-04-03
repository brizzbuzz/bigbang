# Direnv integration.

if not (which direnv | is-empty) {
    $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt? | default [] | append {||
        direnv export json
        | from json --strict
        | default {}
        | items {|key, value|
            let value = do (
                {
                    "PATH": {
                        from_string: {|string_value| $string_value | split row (char esep) | path expand --no-symlink }
                        to_string: {|path_value| $path_value | path expand --no-symlink | str join (char esep) }
                    }
                }
                | merge ($env.ENV_CONVERSIONS? | default {})
                | get ([[value optional insensitive]; [$key true true] [from_string true false]] | into cell-path)
                | if ($in | is-empty) { {|input| $input } } else { $in }
            ) $value

            [$key $value]
        }
        | into record
        | load-env
    })
}
