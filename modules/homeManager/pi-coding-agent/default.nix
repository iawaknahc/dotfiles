{
  pkgs,
  ...
}:
let
  my-ggufs = pkgs.my-ggufs;
  models = my-ggufs.passthru.models;
  providerName = "llama-cpp";
in
{
  home.packages = with pkgs; [
    pi-coding-agent
  ];

  home.sessionVariables = {
    # Disable update check and telemetry.
    # https://pi.dev/docs/latest/settings#telemetry-and-update-checks
    PI_SKIP_VERSION_CHECK = "1";
    PI_OFFLINE = "1";
  };

  home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers = {
      "${providerName}" = {
        baseUrl = "http://127.0.0.1:8080/v1";
        api = "openai-completions";
        apiKey = "unimportant";
        models = builtins.map (model: { id = model.name; } // model.pi) models;
      };
    };
  };

  home.file.".pi/agent/settings.json".text = builtins.toJSON {
    defaultProvider = providerName;
    defaultModel = (builtins.elemAt models 0).name;
    defaultThinkingLevel = "off";
  };
}
