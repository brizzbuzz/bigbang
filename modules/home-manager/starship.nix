{...}: {
  programs.starship.enable = true;
  programs.starship.enableNushellIntegration = true;
  programs.starship.settings = {
    add_newline = false;
    aws.symbol = " ";
    battery = {
      full_symbol = "";
      charging_symbol = "";
      discharging_symbol = "";
      format = "[$percentage]($style)";
    };
    cmd_duration = {
      min_time = 5000;
      show_milliseconds = true;
      format = "took [$duration](bold yellow)";
    };
    directory = {
      truncation_length = 3;
      truncate_to_repo = true;
    };
    git_branch = {
      symbol = " ";
      format = "on [$symbol$branch]($style) ";
    };
    git_status = {
      format = "([$all_status$ahead_behind]($style))";
      ahead = "";
      behind = "";
      conflicted = "";
      deleted = "";
      modified = "";
      renamed = "";
      staged = "";
      stashed = "";
      untracked = "";
    };
    kubernetes.symbol = "行 ";
    memory_usage.symbol = " ";
    nix_shell.symbol = " ";
    package = {
      symbol = " ";
      format = "is [$symbol$version]($style) ";
    };
    python.symbol = " ";
    ruby.symbol = " ";
    rust.symbol = " ";
    status = {
      disabled = false;
      format = "[$symbol$status]($style) ";
      style = "bold red";
      symbol = "❯";
    };
    time = {
      disabled = false;
      format = "at [$time]($style) ";
      style = "bold dimmed";
    };
    username = {
      format = "[$user]($style) ";
      style_user = "bold dimmed";
    };
  };
}
