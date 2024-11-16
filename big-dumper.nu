def dump-repo [output_file: string = "repo_dump.txt"] {
    # Use ripgrep to find all files tracked by git, respecting .gitignore
    let files = (rg --files
        | lines
        | where {|path| not ($path | str contains "/.git/")} # Extra safety to exclude .git directory
    )

    # Create or clear the output file
    "" | save --force $output_file

    # Iterate through files and append their contents with delimiters
    $files | each {|file|
        # Append the delimiter with the file path
        $"(char newline)--- .($file)(char newline)" | save --append $output_file

        # Append the file contents
        open $file --raw | save --append $output_file
    }

    # Return the path to the created file
    $output_file
}

# Example usage:
# dump-repo "my_repo_dump.txt"

