# CLAUDE.md - Bigbang NixOS Configuration

## COMMANDS
- `nix develop` - Enter dev environment
- `nr` - Rebuild local system (darwin-rebuild switch --flake .# or colmena apply-local --impure)
- `nrr <host>` - Rebuild remote system (colmena apply --impure --on <host>)
- `git-cliff` - Generate changelogs
- `tokei` - Code statistics

## CODE STYLE
- Use 2-space indentation for Nix files
- Follow the Nixpkgs style guide conventions
- Organize imports alphabetically
- Keep each host configuration in its own directory under `hosts/`
- Store common functionality in `modules/` with clear separation
- Use camelCase for variables and functions
- Add appropriate comments for complex logic
- Place module options in logical groups
- Prefer explicit over implicit dependencies
- Keep configuration declarative and functional
- Follow standard Nix error handling patterns
- Use descriptive variable names that indicate purpose
- Ensure all modules have clear interfaces with documentation

## REPOSITORY STRUCTURE
- `hosts/` - Machine-specific configurations
- `modules/` - Shared functionality and abstractions
- `flake/` - Flake-related configurations