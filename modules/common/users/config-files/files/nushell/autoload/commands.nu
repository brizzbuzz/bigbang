# Shared shell helpers and small workflow commands.

def choose_value [options: list<string>, prompt: string]: nothing -> string {
    if ($options | is-empty) {
        error make { msg: "No options available" }
    }

    if (which fzf | is-empty) {
        $options | input list $prompt
    } else {
        $options | str join "\n" | ^fzf --prompt $prompt | str trim
    }
}

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
    ] | any {|format| $mime | str contains $format})

    {
        mime: $mime
        size: $size
        is_text: $is_text
    }
}

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

# Create a directory and immediately enter it.
def --env mkcd [dir: path  # Directory to create and enter
] {
    mkdir $dir
    cd $dir
}

# Fuzzy-pick a directory under the current tree and enter it.
def --env cdf [query?: string  # Optional fd search pattern
] {
    if (which fd | is-empty) {
        error make { msg: "cdf requires fd" }
    }

    let pattern = ($query | default "")
    let directories = (["." ] ++ (^fd --type directory --hidden --exclude .git $pattern | lines))
    let selected = (choose_value $directories "dir> ")

    if not ($selected | is-empty) {
        cd $selected
    }
}

# Show which process is bound to a TCP/UDP port.
def "port using" [port: int  # Port number to inspect
] {
    if not (which lsof | is-empty) {
        ^lsof -nP -iTCP:$port -iUDP:$port
    } else if not (which ss | is-empty) {
        ^ss -lntup
        | lines
        | where {|line| $line | str contains $":($port)" }
    } else {
        error make { msg: "port using requires lsof or ss" }
    }
}

# Upload an audiobook to the media library on ganymede.
def upload-audiobook [
    local_file: string  # Local audiobook file to upload
    author: string      # Author directory name
    book: string        # Book directory name
    series?: string     # Optional series directory name
] {
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
    let remote_dir = if ($series == null) {
        $"/data/media/audiobooks/($author)/($book)"
    } else {
        $"/data/media/audiobooks/($author)/($series)/($book)"
    }
    let remote_path = $"($remote_dir)/Audiobook.m4b"

    print $"Uploading ($local_file) to ganymede:($remote_path)..."
    print "Copying file to ganymede..."
    ^scp $local_file $"ganymede:($temp_file)"

    print "Creating directory structure and moving file..."
    ^ssh ganymede $'sudo mkdir -p "($remote_dir)"; sudo mv ($temp_file) "($remote_path)"'

    print $"Audiobook uploaded successfully to ($remote_path)"
}

# Dump repository contents to a text file or clipboard.
def "repo dump" [
    output?: string = "repo_dump.txt"  # Output file path
    --include: string = ""              # Only include matching paths
    --exclude: string = ""              # Exclude matching paths
    --copy(-c)                           # Copy output to clipboard
] {
    let files = (^rg --files | lines | where {|path|
        let include_match = if $include == "" { true } else { $path | str contains $include }
        let is_git = ($path | str contains "/.git/")
        let is_excluded = if $exclude == "" { false } else { $path | str contains $exclude }

        $include_match and (not $is_git) and (not $is_excluded)
    })

    let content = ($files | each {|file|
        let info = (get_file_info $file)
        let size_str = (format_file_size $info.size)
        let header = if $info.is_text {
            $"--- .($file) [($size_str)]"
        } else {
            $"--- .($file) [($size_str)] [BINARY: ($info.mime)]"
        }

        if $info.is_text {
            [$"(char newline)($header)(char newline)" (open $file --raw) (char newline)]
        } else {
            [$"(char newline)($header)(char newline)"]
        }
    } | flatten | str join "")

    if $copy {
        copy_to_clipboard $content
        print "Repository content copied to clipboard!"
    }

    if not ($output == null) {
        $content | save --force $output
        print $"Content saved to ($output)"
        $output
    }
}

alias rd = repo dump
