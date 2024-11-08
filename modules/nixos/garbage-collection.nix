{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;
  nix.optimise.automatic = true;
}
