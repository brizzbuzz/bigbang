[
  (_final: prev: {
    netbird-client = prev.callPackage ./packages/netbird-client.nix {};
    netbird-server = prev.callPackage ./packages/netbird-server.nix {};
  })

  # Disable checks for fish shell
  (_final: prev: {
    fish = prev.fish.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
  })
]
