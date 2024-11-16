{config, lib, ...}: {
  services.open-webui = lib.mkIf config.host.ai.enable {
    enable = true;
    port = config.ports.open-webui;
    environment = {
      OLLAMA_API_BASE_URL = "http://localhost:${toString config.ports.ollama.api}";
      WEBUI_AUTH = "False";
    };
  };
}

