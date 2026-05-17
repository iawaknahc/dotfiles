{
  symlinkJoin,
  stdenvNoCC,
  fetchurl,
}:
let
  outDir = "share/ggufs";
  models = [
    {
      name = "Qwen3.6-35B-A3B";
      model = stdenvNoCC.mkDerivation rec {
        hf_owner = "unsloth";
        hf_model = "Qwen3.6-35B-A3B";
        hf_repo = "${hf_model}-GGUF}";
        hf_quant = "UD-Q4_K_XL";
        hf_filename = "${hf_model}-${hf_quant}.gguf";

        name = hf_filename;
        dontUnpack = true;
        src = fetchurl {
          url = "https://huggingface.co/${hf_owner}/${hf_repo}/resolve/main/${hf_filename}";
          hash = "sha256-cHpVqKQ5fs3kTeDEmdPmjBrR0kDR2mWCa0lJ0QQ/RFA=";
        };
        installPhase = ''
          mkdir -p $out/${outDir}
          cp -R $src $out/${outDir}/${name}
        '';
      };
      mmproj = stdenvNoCC.mkDerivation rec {
        hf_owner = "unsloth";
        hf_model = "Qwen3.6-35B-A3B";
        hf_repo = "${hf_model}-GGUF}";
        hf_filename = "mmproj-F16.gguf";

        name = "${hf_model}-${hf_filename}";
        dontUnpack = true;
        src = fetchurl {
          url = "https://huggingface.co/${hf_owner}/${hf_owner}/resolve/main/${hf_filename}";
          hash = "sha256-iXHuTzMf8KTGCTdPMphLPU5twIbAqjXx1jf60YKeiH8=";
        };

        installPhase = ''
          mkdir -p $out/${outDir}
          cp -R $src $out/${outDir}/${name}
        '';
      };
      pi = {
        input = [
          "text"
          "image"
        ];
        reasoning = true;
        thinkingLevelMap = {
          # off is omitted to mean "Level is supported and uses the provider's default mapping"
          # off = null;
          minimal = null;
          low = null;
          # medium is omitted to mean "Level is supported and uses the provider's default mapping"
          # medium = null;
          high = null;
          xhigh = null;
        };
        compat = {
          thinkingFormat = "qwen-chat-template";
        };
      };
    }
  ];
in
# The common practice of writing a Nix package is to specify `pname` and `version`,
# so that programs like `nix-update` can be used to update the package in an automated way.
# Since we do not expect the model to have updates, and even if it does have an update,
# `nix-update` is not helpful because it does not print download progress when it tries to update a multi-gigabyte file.
# Therefore, we use `name` instead.
symlinkJoin {
  name = "my-ggufs";
  paths = builtins.concatMap (model: [
    model.model
    model.mmproj
  ]) models;
  passthru = {
    inherit outDir models;
  };
}
