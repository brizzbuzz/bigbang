{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "netbird-server";
  version = "0.70.4";

  src = fetchFromGitHub {
    owner = "netbirdio";
    repo = "netbird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tfScscRllUlV1V6D66rfT6JEsReDQfVGryVzNebm0vg=";
  };

  vendorHash = "sha256-IRV1GxdUKgan0GwmBg9acpl7plW01CtEO2FrKrlDdeE=";

  subPackages = ["combined"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  # Upstream's Go tests require network access, matching nixpkgs' NetBird packages.
  doCheck = false;

  postInstall = ''
    mv $out/bin/combined $out/bin/netbird-server
  '';

  meta = {
    description = "Combined NetBird self-hosted server";
    homepage = "https://netbird.io";
    changelog = "https://github.com/netbirdio/netbird/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      nazarewk
      saturn745
      loc
    ];
    mainProgram = "netbird-server";
  };
})
