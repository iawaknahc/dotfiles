{ pkgs, ... }:
let
  coreutils_ =
    with pkgs;
    (coreutils-prefixed.override {
      # Set minimal to false so that the man pages are installed.
      minimal = false;
      # withOpenssl = !minimal by default. Revert it to false.
      withOpenssl = false;
    });
in
{
  home.packages = with pkgs; [
    # The following packages replace programs that ship with macOS.
    bzip2
    coreutils_

    # Wrap ls.
    # This idea is borrowed from fish shell.
    # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/ls.fish
    # Unlike fish shell, we explicitly use the ls from coreutils.
    (writeShellScriptBin "ls" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${coreutils_}/bin/gls -F --color "$@"
      else
        ${coreutils_}/bin/gls "$@"
      fi
    '')

    # Wrap grep.
    # This idea is borrowed from fish shell.
    # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/grep.fish
    # Unlike fish shell, we explicitly use the grep from gnugrep.
    #
    # Caveat
    # The gnugrep package offers egrep and fgrep as well.
    # Since we no longer install the original gnugrep package, they are not installed.
    (writeShellScriptBin "grep" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${gnugrep}/bin/grep --color "$@"
      else
        ${gnugrep}/bin/grep "$@"
      fi
    '')

    # Wrap diff.
    # This idea is borrowed from fish shell.
    # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/diff.fish
    # Unlike fish shell, we explicitly use the diff from diffutils.
    #
    # Caveat
    # The diffutils package offers diff3 and cmp as well.
    # Since we no longer install the original diffutils package, they are not installed.
    (writeShellScriptBin "diff" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${diffutils}/bin/diff --color "$@"
      else
        ${diffutils}/bin/diff "$@"
      fi
    '')

    # In case you need to curl a website whose TLS certificate is signed by
    # a locally trusted CA, like the one created by mkcert,
    # you need to set SSL_CERT_FILE to point to a full CA bundle.
    # You can use the command macos-ca-certs to generate such a CA bundle.
    # curlFull is the curl we are looking for.
    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/top-level/all-packages.nix#L3030
    curlFull

    dig
    file
    findutils
    gawk
    gnumake
    gnused
    gnutar
    gzip
    less
    openssh
    openssl
    patch
    perl
    # Install GNU Time
    # This program does not come with a manpage.
    # Instead, it uses GNU Texinfo.
    time
    unzip
    xz
    zip
  ];
}
