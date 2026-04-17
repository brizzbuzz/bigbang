{inputs}:
final: prev:
  # Reuse upstream's pinned overlay so the package is built in the current
  # nixpkgs context instead of importing a second package set.
  inputs.quickshell-upstream.overlays.default final prev
