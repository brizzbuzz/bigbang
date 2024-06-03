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
      rev = "e9a8da10ed10a005477923f62ec01005aac7a97e";
      sha256 = "C+wmbm6eTt6H2crwLXNZXvArytZLVnrARgKxBJ2wF6s=";
    };

    cargoSha256 = "4hoJ84iLs1YlZ6rj6LcKNuonWsK1DipghjgCHYmaYTk=";

    meta = with lib; {
      description = "Formatter for the KDL config language";
      homepage = "kdl.dev";
      license = licenses.mit;
      maintainers = [maintainers.brizzbuzz];
    };
  }
