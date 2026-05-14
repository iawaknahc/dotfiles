{
  pkgs,
  config,
  ...
}:
let
  my-ggufs = pkgs.my-ggufs;
  outDir = my-ggufs.passthru.outDir;
  models = my-ggufs.passthru.models;
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "llama-cpp";
      paths = [ pkgs.llama-cpp ];
      buildInputs = [ pkgs.makeWrapper ];
      # Wrap `llama-server` so that it is always run with `--models-preset ~/.config/llama-cpp/preset.ini`.
      postBuild = ''
        wrapProgram $out/bin/llama-server \
          --add-flags "--models-preset" \
          --add-flags "${config.xdg.configHome}/llama-cpp/preset.ini"
      '';
    })
    my-ggufs
  ];

  xdg.configFile."llama-cpp/preset.ini".text = ''
    [*]
    offline = true

  ''
  + (builtins.concatStringsSep "" (
    builtins.map (model: ''
      [${model.name}]
      model = ${config.home.profileDirectory}/${outDir}/${model.model.name}
      mmproj = ${config.home.profileDirectory}/${outDir}/${model.mmproj.name}

    '') models
  ));
}
