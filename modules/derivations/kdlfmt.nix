{
  pkgs,
  lib,
}:
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "kdlfmt";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "brizzbuzz";
      repo = pname;
      rev = "fc32f488bb826dc5bec5179ef1ddf5aabacc9b74";
      sha256 = "TiFkyKlYa1hExPaGljJniVlpPaYKUnXhJheSXY38TW4=";
    };

    cargoSha256 = "X4jtHP4Gbq708Q000Wz3hly0x/yx/Vyh5Gio+NcTqng=";

    meta = with lib; {
      description = "Formatter for the KDL config language";
      homepage = "kdl.dev";
      license = licenses.mit;
      maintainers = [maintainers.brizzbuzz];
    };
  }
