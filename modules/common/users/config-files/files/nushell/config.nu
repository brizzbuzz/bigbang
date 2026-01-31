# Nushell Config File
$env.config = {
  show_banner: false,
}

# Environment variables
$env.EDITOR = "zed"

# Path
$env.PATH = ($env.PATH | split row (char esep) | prepend "/usr/local/bin")
$env.PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin') # TODO: Only if on macOS

# Helper function to get file info
def get_file_info [path: string] {
    let mime = (^file --mime-type $path | str trim)
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
        $content | wl-copy
    } else {
        print "Clipboard operation not supported on this OS"
        return
    }
}

# Audiobook upload function
def upload-audiobook [
    local_file: string,
    author: string,
    book: string,
    series?: string
] {
    # Check if file is AAX format (DRM-protected Audible format)
    let file_extension = ($local_file | path parse | get extension | str downcase)
    if $file_extension == "aax" {
        print "Error: AAX files are not supported!"
        print ""
        print "AAX files are DRM-protected Audible audiobooks that cannot be played"
        print "on open-source media servers like AudioBookShelf."
        print ""
        print "To use this audiobook, you need to:"
        print "1. Convert AAX to M4B using tools like:"
        print "   - AAXtoMP3: https://github.com/KrumpetPirate/AAXtoMP3"
        print "   - audible-cli: https://github.com/mkb79/audible-cli"
        print "2. Then upload the converted M4B file instead"
        return null
    }

    let temp_file = "~/temp_audiobook.m4b"

    # Build the remote directory path
    let remote_dir = if ($series == null) {
        $"/data/media/audiobooks/($author)/($book)"
    } else {
        $"/data/media/audiobooks/($author)/($series)/($book)"
    }

    let remote_path = $"($remote_dir)/Audiobook.m4b"

    print $"Uploading ($local_file) to ganymede:($remote_path)..."

    # Upload file to temp location
    print "Copying file to ganymede..."
    ^scp $local_file $"ganymede:($temp_file)"

    # Create directory structure and move file
    print "Creating directory structure and moving file..."
    ^ssh ganymede $'sudo mkdir -p "($remote_dir)"; sudo mv ($temp_file) "($remote_path)"'

    print $"Audiobook uploaded successfully to ($remote_path)"
}

# Repository dump command
def "repo dump" [
    output?: string = "repo_dump.txt"  # Optional output file name
    --include: string = "",            # Additional files to include pattern
    --exclude: string = "",            # Files to exclude pattern
    --copy(-c)                         # Copy to clipboard
] {
    let files = (^rg --files | lines | where {|path|
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

# Aliases
alias nr = sudo darwin-rebuild switch --flake .#
alias rd = repo dump
alias zj = zellij

# Remote rebuild function - builds remote hosts if no host specified
def nrr [host?: string] {
  if ($host == null) {
    print "No host specified, building remote hosts (ganymede, callisto)..."
    ^colmena apply --impure --on ganymede,callisto
  } else {
    ^colmena apply --impure --on $host
  }
}

# =============================================================================
# Zoxide integration
# =============================================================================

# Initialize hook to add new entries to the database.
$env.config = (
  $env.config?
  | default {}
  | upsert hooks { default {} }
  | upsert hooks.env_change { default {} }
  | upsert hooks.env_change.PWD { default [] }
)
let __zoxide_hooked = (
  $env.config.hooks.env_change.PWD | any { try { get __zoxide_hook } catch { false } }
)
if not $__zoxide_hooked {
  $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
    __zoxide_hook: true,
    code: {|_, dir| zoxide add -- $dir}
  })
}

# Jump to a directory using only keywords.
def --env --wrapped __zoxide_z [...rest: string] {
  let path = match $rest {
    [] => {'~'},
    [ '-' ] => {'-'},
    [ $arg ] if ($arg | path expand | path type) == 'dir' => {$arg}
    _ => {
      zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
    }
  }
  cd $path
}

# Jump to a directory using interactive search.
def --env --wrapped __zoxide_zi [...rest:string] {
  cd $'(zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}

alias z = __zoxide_z
alias zi = __zoxide_zi

# =============================================================================
# Atuin integration
# =============================================================================

module compat {
  export def --wrapped "random uuid -v 7" [...rest] { atuin uuid }
}
use (if not (
    (version).major > 0 or
    (version).minor >= 103
) { "compat" }) *

$env.ATUIN_SESSION = (random uuid -v 7 | str replace -a "-" "")
hide-env -i ATUIN_HISTORY_ID

# Magic token to make sure we don't record commands run by keybindings
let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"

let _atuin_pre_execution = {||
    if ($nu | get history-enabled?) == false {
        return
    }
    let cmd = (commandline)
    if ($cmd | is-empty) {
        return
    }
    if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
        $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
    }
}

let _atuin_pre_prompt = {||
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

def _atuin_search_cmd [...flags: string] {
    if (version).minor >= 106 or (version).major > 0 {
        [
            $ATUIN_KEYBINDING_TOKEN,
            ([
                `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline), ATUIN_SHELL: nu } {`,
                    ([
                        'let output = (run-external atuin search',
                        ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                        'e>| str trim)',
                    ] | flatten | str join ' '),
                    'if ($output | str starts-with "__atuin_accept__:") {',
                    'commandline edit --accept ($output | str replace "__atuin_accept__:" "")',
                    '} else {',
                    'commandline edit $output',
                    '}',
                `}`,
            ] | flatten | str join "\n"),
        ]
    } else {
        [
            $ATUIN_KEYBINDING_TOKEN,
            ([
                `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`,
                    'commandline edit',
                    '(run-external atuin search',
                        ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                    ' e>| str trim)',
                `}`,
            ] | flatten | str join ' '),
        ]
    } | str join "\n"
}

$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = (
    $env.config | upsert hooks (
        $env.config.hooks
        | upsert pre_execution (
            $env.config.hooks | get pre_execution? | default [] | append $_atuin_pre_execution)
        | upsert pre_prompt (
            $env.config.hooks | get pre_prompt? | default [] | append $_atuin_pre_prompt)
    )
)

$env.config = ($env.config | default [] keybindings)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: { send: executehostcommand cmd: (_atuin_search_cmd) }
        }
    )
)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuup}
                    {send: executehostcommand cmd: (_atuin_search_cmd '--shell-up-key-binding') }
                ]
            }
        }
    )
)

# =============================================================================
# Direnv integration
# =============================================================================

$env.config = ($env.config | default {} | merge {
    hooks: ($env.config.hooks? | default {} | merge {
        pre_prompt: ($env.config.hooks?.pre_prompt? | default [] | append {||
            direnv export json
            | from json --strict
            | default {}
            | items {|key, value|
                let value = do (
                    {
                      "PATH": {
                        from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                        to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                      }
                    }
                    | merge ($env.ENV_CONVERSIONS? | default {})
                    | get ([[value, optional, insensitive]; [$key, true, true] [from_string, true, false]] | into cell-path)
                    | if ($in | is-empty) { {|x| $x} } else { $in }
                ) $value
                return [ $key $value ]
            }
            | into record
            | load-env
        })
    })
})
