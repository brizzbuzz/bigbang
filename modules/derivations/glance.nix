{pkgs-unstable, ...}:
with pkgs-unstable;
  buildGoModule {
    name = "glance";
    src = fetchFromGitHub {
      owner = "glanceapp";
      repo = "glance";
      rev = "v0.4.0";
      hash = "sha256-vcK8AW+B/YK4Jor86SRvJ8XFWvzeAUX5mVbXwrgxGlA=";
    };

    vendorHash = "sha256-Okme73vLc3Pe9+rNlmG8Bj1msKaVb5PaIBsAAeTer6s=";
  }
