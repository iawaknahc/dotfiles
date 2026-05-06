{ pkgs, ... }:
{
  home.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "ascii";
      src = ./.;
      buildInputs = [ pkgs.pandoc ];
      installPhase = ''
        mkdir -p $out/share/man/man7
        pandoc -D man > man.template
        pandoc --verbose $src/ascii.md --to man --template man.template > $out/share/man/man7/ascii.7
      '';
    })
  ];
}
