{inputs}: {
  meta = {
    specialArgs = {
      inherit inputs;
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "ventoy-1.1.10"
          ];
        };
        overlays = import ../modules/overlays;
      };
    };
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config = {
        permittedInsecurePackages = [
          "ventoy-1.1.10"
        ];
      };
      overlays = import ../modules/overlays;
    };
  };

  frame = {
    imports = [../hosts/frame/configuration.nix];
    deployment = {
      targetHost = "192.168.11.214";
      targetUser = "ryan";
      allowLocalDeployment = true;
      buildOnTarget = true;
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