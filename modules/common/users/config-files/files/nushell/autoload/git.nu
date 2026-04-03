# Git-specific shell helpers.

# Jump to the current repository root.
def --env "git root" [] {
    let root = (^git rev-parse --show-toplevel | str trim)

    if ($root | is-empty) {
        error make { msg: "Not inside a git repository" }
    }

    cd $root
}

# Jump to a git worktree by branch name.
def --env gwt [name?: string  # Optional branch name filter
] {
    let rows = (
        git worktree list --porcelain
        | lines
        | where {|line| $line | str starts-with "worktree " }
        | each {|line|
            let path = ($line | str replace "worktree " "")
            let worktree = (^git -C $path branch --show-current | str trim)

            {
                name: $worktree
                path: $path
            }
        }
        | where name != ""
    )

    if ($rows | is-empty) {
        print -e "No git worktrees found"
        return
    }

    let chooser = {|options: list<string>, prompt: string|
        if (which fzf | is-empty) {
            $options | input list $prompt
        } else {
            $options | str join "\n" | ^fzf --prompt $prompt | str trim
        }
    }

    let choose_path = {|candidates, prompt|
        let options = ($candidates | each {|row| $"($row.name)\t($row.path)" })
        let selected = (do $chooser $options $prompt)

        if ($selected | is-empty) {
            null
        } else {
            let parsed = ($selected | parse "{name}\t{path}")
            if ($parsed | is-empty) { null } else { $parsed | first | get path }
        }
    }

    let target = if ($name | is-empty) {
        do $choose_path $rows "worktree> "
    } else {
        let matches = ($rows | where {|row| $row.name == $name or ($row.name | str contains $name) })

        if ($matches | is-empty) {
            error make { msg: $"No worktree matches '($name)'" }
        } else if ($matches | length) == 1 {
            $matches | first | get path
        } else {
            do $choose_path $matches "multiple> "
        }
    }

    if $target != null {
        cd $target
    }
}
