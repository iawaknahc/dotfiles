{ ... }:
{
  home.sessionVariablesExtra = ''
    if [ -z "$OPENROUTER_API_KEY" ]; then
      export OPENROUTER_API_KEY="$(op read --no-newline op://Personal/openrouter-api-key/credential)"
    fi
  '';

  home.file.".codex/config.yaml" = {
    enable = true;
    text = ''
      provider: "openrouter"
      model: "anthropic/claude-3.7-sonnet"
    '';
  };
}
