# Nix and deployment helpers.

# Rebuild the local host using the platform-appropriate command.
def nr [] {
    if $nu.os-info.name == "macos" {
        ^sudo darwin-rebuild switch --flake .#
    } else if $nu.os-info.name == "linux" {
        ^sudo colmena apply-local --impure
    } else {
        error make { msg: $"Unsupported OS for nr: ($nu.os-info.name)" }
    }
}

# Build or deploy remote NixOS hosts with dirty-worktree allowances.
def nrr [host?: string  # Optional remote host name
] {
    let existing_nix_config = ($env.NIX_CONFIG | default "" | str trim -r -c "\n")
    let nrr_nix_config = ($existing_nix_config + "\nallow-dirty = true\nallow-dirty-locks = true\nwarn-dirty = false\nwrite-lock-file = false\n")

    if ($host == null) {
        print "No host specified, building remote hosts (ganymede, callisto)..."
        with-env { NIX_CONFIG: $nrr_nix_config } { ^colmena apply --impure --on ganymede,callisto }
    } else {
        with-env { NIX_CONFIG: $nrr_nix_config } { ^colmena apply --impure --on $host }
    }
}
