{inputs}: {
  meta = {
    specialArgs = {
      inherit inputs;
    };
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "ventoy-1.1.12"
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
      targetHost = "192.168.11.200";
      targetUser = "root";
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
  };

  ganymede = {
    imports = [../hosts/ganymede/configuration.nix];
    deployment = {
      targetHost = "192.168.11.39";
      targetUser = "ryan";
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
  };
}
