{
  config,
  lib,
  ...
}: {
  services.open-webui = lib.mkIf config.host.ai.enable {
    enable = true;
    host = "0.0.0.0";
    port = config.ports.open-webui;
    environment = {
      OLLAMA_API_BASE_URL = "http://localhost:${toString config.ports.ollama.api}";
      WEBUI_AUTH = "True";
      DATABASE_URL = "postgresql://openwebui:openwebui@localhost:5432/openwebui";
      VECTOR_DB = "pgvector";
      ENABLE_SIGNUP = "True";
      DEFAULT_USER_ROLE = "pending";
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.host.ai.enable [
    config.ports.open-webui
  ];
}
