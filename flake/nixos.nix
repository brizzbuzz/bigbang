{inputs}: {
  meta = {
    specialArgs = {
      inherit inputs;
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = import ../modules/overlays ++ [inputs.hyprpanel.overlay];
      };
    };
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = import ../modules/overlays ++ [inputs.hyprpanel.overlay];
    };
  };

  frame = {
    imports = [../hosts/frame/configuration.nix];
    deployment = {
      allowLocalDeployment = true;
      targetUser = "ryan";
    };
  };

  callisto = {
    imports = [../hosts/callisto/configuration.nix];
    deployment = {
      targetHost = "callisto.chateaubr.ink";
      targetUser = "root";
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
  };

  ganymede = {
    imports = [../hosts/ganymede/configuration.nix];
    deployment = {
      targetHost = "ganymede.chateaubr.ink";
      targetUser = "ryan";
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
  };
}
