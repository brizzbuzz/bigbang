{pkgs, ...}:
with pkgs;
  buildGoModule {
    name = "speedtest";
    src = fetchFromGitHub {
      owner = "librespeed";
      repo = "speedtest-go";
      rev = "v1.1.5";
      hash = "sha256-ywGrodl/mj/WB25F0TKVvaV0PV4lgc+KEj0x/ix9HT8=";
    };

    vendorHash = "sha256-ev5TEv8u+tx7xIvNaK8b5iq2XXF6I37Fnrr8mb+N2WM=";
  }
