   [
    (final: prev: {
      vimPlugins =
        prev.vimPlugins
        // {
          supermaven = prev.callPackage ./../derivations/supermaven-nvim.nix {};
        };
    })
  ]
