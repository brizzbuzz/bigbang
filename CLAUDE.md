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
  - `modules/darwin/app-profiles.nix` - Profile-based app management
  - `modules/home-manager/profiles/` - User profile configurations
- `flake/` - Flake-related configurations

## MULTI-USER CONFIGURATION

### User Profiles
- `personal` - Full access including Apple ID apps (Xcode), entertainment, development tools
- `work` - Business apps only, no Apple ID dependencies, limited development tools

### User Configuration
Configure users in host configuration:
```nix
host = {
  users = {
    ryan = {
      name = "ryan";
      profile = "personal";
      isPrimary = true;
      homeManagerEnabled = true;
    };
    Work = {
      name = "Work";
      profile = "work";
      isPrimary = false;
      homeManagerEnabled = true;
    };
  };

  profiles = {
    personal = {
      entertainmentApps = true;     # Discord, Spotify, Steam
      developmentApps = true;       # JetBrains, Docker, etc.
      personalApps = true;          # Personal productivity
    };
    work = {
      businessApps = true;          # Notion, Zoom, Chrome
      restrictedApps = false;       # Limited app access
      developmentApps = false;      # No dev tools by default
    };
  };
};
```

### Available Darwin Configurations
- `pip` - 14" MacBook Pro with both users (ryan primary)
- `ember` - 16" MacBook Pro with both users (ryan primary)
- `dot` - Mac Mini with both users (ryan primary)

### Using the Configuration
```bash
# Build and switch to configuration for 14" MBP
darwin-rebuild switch --flake .#pip

# Build and switch to configuration for 16" MBP
darwin-rebuild switch --flake .#ember

# Build and switch to configuration for Mac Mini
darwin-rebuild switch --flake .#dot

# Both ryan (personal) and Work (work profile) users are available
# Apps are automatically segregated based on user profiles
```

## NETWORK ARCHITECTURE
- Local network domain: chateaubr.ink
- Public domain: rgbr.ink (configured in Cloudflare with proxy mode)
- Machines accessible locally or via Wireguard as [hostname].chateaubr.ink
- callisto runs Caddy server that delegates traffic from rgbr.ink to appropriate services
- ganymede runs Jellyfin media server accessible via media.rgbr.ink
