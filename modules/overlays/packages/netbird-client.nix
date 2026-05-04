{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "netbird-client";
  version = "0.70.4";

  src = fetchFromGitHub {
    owner = "netbirdio";
    repo = "netbird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tfScscRllUlV1V6D66rfT6JEsReDQfVGryVzNebm0vg=";
  };

  vendorHash = "sha256-IRV1GxdUKgan0GwmBg9acpl7plW01CtEO2FrKrlDdeE=";

  nativeBuildInputs = [installShellFiles];

  subPackages = ["client"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  # Upstream's Go tests require network access, matching nixpkgs' NetBird packages.
  doCheck = false;

  postPatch = ''
    # make it compatible with systemd's RuntimeDirectory
    substituteInPlace client/cmd/root.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
  '';

  postInstall = ''
    mv $out/bin/client $out/bin/netbird

    installShellCompletion --cmd netbird \
      --bash <($out/bin/netbird completion bash) \
      --fish <($out/bin/netbird completion fish) \
      --zsh <($out/bin/netbird completion zsh)
  '';

  meta = {
    description = "NetBird client";
    homepage = "https://netbird.io";
    changelog = "https://github.com/netbirdio/netbird/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      nazarewk
      saturn745
      loc
    ];
    mainProgram = "netbird";
  };
})
