{ pkgs, lib, ... }:
let
  # This is the last known version that does not suffer from
  # https://github.com/openai/codex/issues/1005
  # https://github.com/openai/codex/issues/1057
  #
  # Apparently, the TypeScript version is not maintained, and efforts were spent on the Rust version.
  version = "0.1.2505160811";

  provider = "openrouter";
  # On 2025-05-28, I found that codex-mini-latest is unresponsive.
  # See https://github.com/openai/codex/issues/1140
  model = "google/gemini-2.5-flash-preview-05-20"; # https://openrouter.ai/google/gemini-2.5-flash-preview-05-20

  tomlFormat = pkgs.formats.toml { };
  yamlFormat = pkgs.formats.yaml_1_1 { };
in
{
  home.sessionVariablesExtra = ''
    if [ -z "$OPENROUTER_API_KEY" ]; then
      export OPENROUTER_API_KEY="$(op read --no-newline op://Personal/openrouter-api-key/credential)"
    fi
  '';

  home.file.".codex/config.yaml".source = (
    yamlFormat.generate "codex-yaml" {
      inherit model;
      inherit provider;
      approvalMode = "suggest";
      providers = {
        openrouter = {
          name = "openrouter";
          baseURL = "https://openrouter.ai/api/v1";
          envKey = "OPENROUTER_API_KEY";
        };
      };
    }
  );

  home.file.".codex/config.toml".source = (
    tomlFormat.generate "codex-toml" {
      inherit model;
      model_provider = provider;
      approval_policy = "unless-allow-listed";
      sandbox_permissions = [ "disk-full-read-access" ];
      file_opener = "none";
    }
  );

  home.file.".codex/AGENTS.md".text = ''
    - Only use git commands when I explicitly tell you to do so.
  '';

  home.packages = with pkgs; [
    (stdenv.mkDerivation {
      name = "codex";
      src = ./.;
      buildInputs = [
        makeBinaryWrapper
      ];
      buildPhase = ''
        cp ${writeShellScript "codex" ''
          npx -y @openai/codex@${version} "$@"
        ''} codex
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp codex $out/bin/codex
        wrapProgram $out/bin/codex \
          --prefix PATH : ${
            lib.makeBinPath [
              # Add some basic utilities for codex to use.
              coreutils
              diffutils
              findutils
              # codex requires node >= 22 to run.
              nodejs_22
            ]
          }
      '';
    })
  ];
}
