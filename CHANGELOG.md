# Changelog

All notable changes to this project will be documented in this file.

## [0.6.0] - 2025-03-16

### 🚀 Features

- Yubi configuration
- Unify home manager across darwin and nix
- Odyssey work setup (#49)
- Cloudy back online (mostly) (#50)
- *(git)* Streamline git configuration and user settings (#52)
- Zen browser and zod
- *(networking)* Add Caddy reverse proxy configuration (#54)
- Deploy jellyfin to gigame (#56)
- Grafana metrics server on cloudy (#57)
- Prometheus (#58)
- *(house)* Start of home assistance
- *(metrics)* Got the bones of the lgtm module in place (#60)
- *(nixos)* Mimir configuration and grafana data source (#64)
- *(nixos)* Basic alloy collector deployment (#65)
- *(nixos)* Deploy loki (#67)
- *(nixos)* Tempo deployment (#68)
- *(nixos)* Alloy now pushes logs to loki (#69)
- Node exporter on both servers (#71)

### 🐛 Bug Fixes

- *(darwin)* For now disable 1password home manager secrets
- Update cloudy disko config
- Cloudy and gigame alive in server mode
- Macbook name

### 🚜 Refactor

- Move alloy configs to host definition (#70)

### ⚙️ Miscellaneous Tasks

- Update flake
- Update lock and format
- Remove luks from gigame for now
- Update locks, touch up configs and remove darwin specific hm config
- Remove nixvim config
- *(darwin)* Remove outdated config val
- *(darwin)* Remove alacritty
- *(darwin)* Remove dup config
- Qol updates (#59)
- Reorganize minio and lgtm modules (#62)
- *(darwin)* Add notion to casks (#63)
- *(nixos)* Remove gigantic swap files from cloudy and gigame (#66)

## [0.5.0] - 2024-12-04

### 🚀 Features

- Nushell derivation (#34)
- Add jj to flake
- Launch glance as systemd service
- Soft serve (#37)
- Enable postgres db for all systems
- Upgrade nixos to 24.05
- Misc terminal updates
- Add kdlfmt with neovim integration
- Portfolio dev env floating panes
- Adjustments to zellij default panels
- Basic revv work setup
- Add additional packages to revv laptop
- More macos integration
- Homebrew managed by nix
- More darwin specific stuff
- Add git signing key as configurable value
- Add git signing key as configurable value
- Add jellyfin server config
- Pg noevim
- Add posting tui
- Revvbook -> macme
- Transmission enabled
- Add digikam
- Move several dots to nix
- More dots move to nix files
- Darwin consolidation
- Improved nix dot consolidation
- Integrate nixvim to home manager
- Nuking old nvim, going all in on nixvim
- *(nvim)* Enable telescope
- Nixvim file structure
- Nvim dashboard plugin
- Nvim plugins and touch ups
- Use overlay to add custom neovim plugin
- Basic nvim lsp support
- Speedtest-go derivation
- Reworking hypr confs
- Disable plasma, integrate sddm and add theme
- Steps towards a waybar i actually like
- Reintegrated homebrew into home manager
- Waybar looking goooood
- Add power button to waybar
- Sketchybar
- Aerospace
- *(nvim)* Crates-nvim
- *(darwin)* Proxyman
- Tailscale on macos
- Bump entirely to unstable, enable attic on cloudy
- Enable minio object storage server
- Avante nvim integration
- Integrate opnix
- Move minio root creds to 1password
- Store attic connection details in 1password
- Improved postgres config
- Big dumper (plus a readme)
- Maximally epic readme
- I lied, the prophecy is now complete
- Repo dumper command
- Turn on ollama and open webui
- Add back jetbrain ides
- I destroyed everything, yay nix
- Hyprpanel, among other things
- Spacedrive
- Add a couple mac apps
- Updated disko config for gigame
- Enable gleam lsp
- Wow i finally diskod

### 🐛 Bug Fixes

- Resolved issue where custom options were not present in home manager
- Remove automatic garbage collection
- Set new hw config for cloudy
- Only enable glance and soft serve on cloudy
- Soft serve systemd service working
- Bug in zellij config
- Steam was bugged
- Wofi broken
- Enable iwd autoconnect
- Switch back to nm from connman cuz connman is pita
- Temporarily remove home manager from darwin setup
- Remove zellij default layout
- Infinite rec on nixos
- Atuin script
- Misconfigured work ssh config
- Forgot to adjust file location
- Enable unstable pkgs on darwin
- Remove homebrew from darwin install
- Wayland not on darwin
- Ssh config not symlinked to config dir
- Support 1password auth agent for darwin and nix
- Nvim color scheme and bat config warning
- Add brew to nushell path
- Build broken on nixos
- Darwin version mismatch silence
- Bump home-manager to master to avoid version error
- Rollback minio attic storage for the moment
- Comment out shadow hypr config section, broken on latest version
- Comment out broken hypr conf section
- Monitor refresh rate on desktop
- Nr and nrr commands now system dependent
- Monitor refresh rate
- *(darwin)* Zsh compinit
- *(darwin)* Config function for multiple darwin devices
- Nerdfont dedicated packages

### ⚙️ Miscellaneous Tasks

- Enable local deploy for cloudy
- Only install steam if desktop is enabled
- Update lock file
- Explicitly set pg version to 16
- Bump kdlfmt
- Misc bind updates to hyprland conf
- Misc updates to hypr key bindings
- Remove tailwind css lang server (why was it there)
- Misc updates to nvim
- Remove autolaunch for brave
- Formatting
- Enable blank home manager for darwin
- Remove todo
- Add a few git aliases
- Flake update
- Neovim touchups
- Update lock file
- Neovim deps
- Neovim touchup
- Darwin neovim touchup
- Ruff neovim integration
- Update lock
- Change posting orientation
- Remove espanso for now since its broken with wayland
- Update lock
- Cloudy build on machine
- Enable a few nvim plugins
- Misc flake updates and neovim plugins
- Remove unnecessary derivations
- Themes and stuff
- Add jetbrains nerdfont to mac
- Fix up stuff on macos
- Restructure flake file
- *(darwin)* Disable aerospace for now cuz it kinda sucks
- Reenable nvim lsp
- Changelog
- Format files
- Switch to stdenv isDarwin
- Switch to stdenv isDarwin for real
- Add impure flag to system build aliases
- Update lock file
- Bump version

## [0.4.0] - 2024-05-15

### 🚀 Features

- Add home manager modules to cloudy :)
- Woooo I made a derivation!
- Introduce dummy overlay for future reference
- Wlogout icons n stuff
- Host-specific hyprland config (#33)
- Add derivation for glance dashboard

### 🐛 Bug Fixes

- Flip boolean for remote build apply
- Go back to nil for nix lang server
- Remove old hypr conf

### ⚙️ Miscellaneous Tasks

- Update lock file
- Update lock file
- Update lock file
- Update lock file
- Bump file watch count
- Update changelog

## [0.3.0] - 2024-04-12

### 🚀 Features

- Postgres lsp and autoformat
- Add just support for neovim
- Move cloudy config primarily to modules
- Make 1password setup configurable
- Make 1password setup configurable
- Huge refactor to nixos modules to improve configurability
- Refactor home manager into module directory

### 🐛 Bug Fixes

- Raise inotify limits
- Atuin now properly binding to ctrl-r
- Use default.nix to import files
- Abstract more config into nixos modules

### ⚙️ Miscellaneous Tasks

- Misc touch ups
- Generate changelog for 0.3.0 release

## [0.2.0] - 2024-04-08

### 🚀 Features

- Pueue (#28)

### 🐛 Bug Fixes

- Ignore direnv folder
- Ignore devenv folder
- Enable support for magic trackpad
- Actually set up atuin
- Atuin history populated
- Move gopls to unstable

### ⚙️ Miscellaneous Tasks

- Misc updates
- Changelog update prior to 0.2.0

## [0.1.0] - 2024-04-03

### 🚀 Features

- Initial commit
- Basic hyprland config plus misc stuff
- More misc setup
- Neovim base configuration
- Starship
- Waybar config
- Added cloudy
- Lots of theme updates and some minor nvim cleanup
- Move home manager to module approach
- Misc
- Macos (#2)
- Add tokei
- Add protonvpn for darwin
- Move lsp logic to nix
- Misc ricing (#3)
- Add docker on mac
- Install transmission
- Misc ricing
- Neovim ai plugins
- Transmission on mac
- Use builtin for current system... among other changes (#6)
- Split neovim plugins into dedicated config files
- Waybar comeback?
- Switch to nixd
- Added framework laptop
- Setup framework laptop, and general cleanup
- Xmodmap dump
- Bye bye osx (among other improvements)
- Enable fingerprint scanning
- Nix-direnv config
- Added zoom and ledger apps
- Deploy cloudy through the power of Colmena
- Colmena now manages desktop
- Finish migrating all devices to colmena
- Move common modules to dedicated folder with defaults
- Enable yubikey password management
- Polkit is working on hyprland!!!!
- Integrate dev shell via devenv, and introduce changelog via git-cliff :)

### 🐛 Bug Fixes

- Adjust ssh config based on desktop environment
- Add mise to cloudy
- Zoxide bug
- Unstable pkgs on macos
- Waybar was broken :(
- Nu config broken on osx
- I deleted spotify and discord?
- Nvidia missing config attribute
- Add myself to trusted users
- Allow colmena local apply from desktop

### ⚙️ Miscellaneous Tasks

- Set git config email to verified email
- Lauch 1password on startup in silent mode
- Format
- Misc 1/10/24 (#1)
- More specific systems folder
- Forward ssh agent on connect to cloudy
- Testing
- Formatting
- Update lock
- Misc packages, some neovim config, and comments
- Formatting
- Update lock
- Updates and some minor neovim tweaks
- Misc updates
- Misc
- Back to stable
- Bump some pkgs to unstable
- Minor hyprland config updates and lock update
- Misc touchups
- Update lock
- Format
- Add neovim deps to mbp
- Misc
- Misc
- Gleam deps
- Misc mac updates (#4)
- Wayland 1pasword launcher
- Misc updates
- Add latest channel for nixpkgs to add devenv
- Misc touchup
- Some misc comments
- Move alejandra to common
- Comment
- Adjust git commits and format lua code
- Add colmena cli
- Migrate remaining files to host folder
- Remove old config options
- Misc golang neovim stuff
- Tag for 0.1.0 release

### Ack

- The power of nix compels you

<!-- generated by git-cliff -->
