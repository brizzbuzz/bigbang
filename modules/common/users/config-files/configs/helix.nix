{lib, ...}: let
  # Profile-based defaults for Helix configuration
  profileDefaults = {
    personal = {
      theme = "dark-synthwave"; # Vibrant neon theme matching Synthwave terminal
    };
    work = {
      theme = "github_dark"; # Professional theme matching Github Dark terminal
    };
  };

  # Resolve helix theme for a user (profile defaults + per-user overrides)
  getHelixTheme = user: let
    defaults = profileDefaults.${user.profile};
  in
    if user.helix.theme or null != null
    then user.helix.theme
    else defaults.theme;

  # Generate helix config content
  mkHelixConfig = theme: ''
    # Helix Editor Configuration
    # Optimized for Rust, TypeScript, Nix, and Go development

    theme = "${theme}"

    [editor]
    # UI preferences
    line-number = "relative"
    mouse = true
    middle-click-paste = true
    scroll-lines = 3
    scrolloff = 8
    cursorline = true
    cursorcolumn = false
    gutters = ["diagnostics", "spacer", "line-numbers", "spacer", "diff"]
    color-modes = true
    true-color = true
    rulers = [80, 120]
    bufferline = "multiple"
    popup-border = "all"
    text-width = 100
    workspace-lsp-roots = []
    default-line-ending = "lf"

    # Editor behavior
    auto-completion = true
    auto-format = true
    auto-save = false
    auto-pairs = true
    auto-info = true
    completion-trigger-len = 2
    completion-replace = true
    preview-completion-insert = true
    idle-timeout = 250
    insert-final-newline = true

    # Search
    search = { smart-case = true, wrap-around = true }

    # Whitespace rendering
    [editor.whitespace]
    characters = { space = "·", nbsp = "⍽", tab = "→", newline = "⏎", tabpad = "·" }

    [editor.whitespace.render]
    space = "none"
    nbsp = "all"
    tab = "all"
    newline = "none"

    # Indent guides
    [editor.indent-guides]
    render = true
    character = "│"
    skip-levels = 0

    # Cursor shape
    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    # LSP behavior
    [editor.lsp]
    enable = true
    display-messages = true
    auto-signature-help = true
    display-inlay-hints = true
    display-signature-help-docs = true
    snippets = true
    goto-reference-include-declaration = true

    # File picker
    [editor.file-picker]
    hidden = false
    follow-symlinks = true
    deduplicate-links = true
    parents = true
    ignore = true
    git-ignore = true
    git-global = true
    git-exclude = true
    max-depth = 6

    # Statusline
    [editor.statusline]
    left = ["mode", "spinner", "version-control", "file-name", "file-modification-indicator"]
    center = []
    right = ["diagnostics", "selections", "register", "position", "file-encoding"]
    separator = "│"
    mode.normal = "NORMAL"
    mode.insert = "INSERT"
    mode.select = "SELECT"

    # Soft wrap
    [editor.soft-wrap]
    enable = false
    max-wrap = 25
    max-indent-retain = 40
    wrap-indicator = "↪ "
    wrap-at-text-width = false

    # Keys configuration
    [keys.normal]
    # Quick save
    C-s = ":write"
    # Quick quit
    C-q = ":quit"
    # Buffer navigation
    C-h = ":buffer-previous"
    C-l = ":buffer-next"
    C-w = ":buffer-close"
    # File explorer
    space.e = ":open ."
    # Format document
    space.f = ":format"
    # Toggle line numbers
    space.n = ":toggle line-number"
    # Toggle soft wrap
    space.w = ":toggle soft-wrap"

    [keys.insert]
    # Quick save from insert mode
    C-s = ["normal_mode", ":write"]
    # Exit insert mode
    j.k = "normal_mode"

    [keys.select]
    # Quick save from select mode
    C-s = ["normal_mode", ":write"]
  '';
in {
  # Helix editor configuration
  mkHelixScript = {
    user,
    homeDir,
    enabled,
  }: let
    theme = getHelixTheme user;
    helixConfig = mkHelixConfig theme;
    helixLanguages = builtins.readFile ../files/helix/languages.toml;
  in
    lib.optionalString enabled ''
        # Helix configuration
        mkdir -p "${homeDir}/.config/helix"

        [ -L "${homeDir}/.config/helix/config.toml" ] && rm "${homeDir}/.config/helix/config.toml"
        cat > "${homeDir}/.config/helix/config.toml" << 'EOFHELIXCONFIG'
      ${helixConfig}
      EOFHELIXCONFIG
        chmod 644 "${homeDir}/.config/helix/config.toml"

        [ -L "${homeDir}/.config/helix/languages.toml" ] && rm "${homeDir}/.config/helix/languages.toml"
        cat > "${homeDir}/.config/helix/languages.toml" << 'EOFHELIXLANG'
      ${helixLanguages}
      EOFHELIXLANG
        chmod 644 "${homeDir}/.config/helix/languages.toml"
    '';
}
