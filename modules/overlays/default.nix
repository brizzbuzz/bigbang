[
  # Disable checks for fish shell
  (_final: prev: {
    fish = prev.fish.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
  })
  (final: _prev: {
    datadog-mcp-cli = final.callPackage ./datadog-mcp-cli.nix {};
  })
]
