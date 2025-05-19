{ pkgs, ... }:
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
  home.file.".codex/instructions.md" = {
    enable = true;
    text = ''
      - Only use git commands when I explicitly tell you to do so.
    '';
  };
  home.packages = [
    (pkgs.writeScriptBin "codex" ''
      #!/bin/sh

      # According to my own bisect testing, this version is the last know version that is not affected by
      # 1. This bug https://github.com/openai/codex/issues/1005
      # 2. Does not explicitly require nodejs 22 to run.
      ${pkgs.nodejs_22}/bin/npx -y @openai/codex@0.1.2505160811 "$@"
    '')
  ];
}
