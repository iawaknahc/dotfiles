{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.symlinkJoin {
      name = "yamlfmt";
      paths = [ yamlfmt ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        makeWrapper $out/bin/yamlfmt $out/bin/kyamlfmt \
          --add-flags "-kyaml"
      '';
    })
    yaml-language-server
  ];
}
