[
  (_final: prev: {
    netbird-server = prev.callPackage ./packages/netbird-server.nix {};
  })

  # Disable checks for fish shell
  (_final: prev: {
    fish = prev.fish.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
  })
]
