{
  config,
  lib,
  ...
}: {
  services.ollama = lib.mkIf config.host.ai.enable {
    enable = true;
    acceleration = lib.mkIf config.host.gpu.nvidia.enable "cuda";
    port = config.ports.ollama.api;
  };
}
