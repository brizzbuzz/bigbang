[
  # Disable checks for fish shell
  (_final: prev: {
    fish = prev.fish.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
  })
]
