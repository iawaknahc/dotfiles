{ pkgs, ... }:
{
  home.packages = with pkgs; [
    coreutils-prefixed
    (stdenv.mkDerivation {
      name = "coreutils-prefixed-manpages";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/man/man1/
        cp -R ${coreutils-full}/share/man/man1/. $out/share/man/man1/
        cd $out/share/man/man1
        for f in *.gz; do mv "$f" g"$f"; done
      '';
    })

    file
    findutils
    gnumake
    openssl

    # Install GNU Time
    # This program does not come with a manpage.
    # Instead, it uses GNU Texinfo.
    time
  ];
}
