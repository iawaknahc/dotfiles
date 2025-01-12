{ pkgs, ... }:
{
  home.packages = [
    # The following packages replace programs that ship with macOS.
    pkgs.bzip2
    pkgs.coreutils-prefixed

    # In case you need to curl a website whose TLS certificate is signed by
    # a locally trusted CA, like the one created by mkcert,
    # you need to set SSL_CERT_FILE to point to a full CA bundle.
    # You can use the command macos-ca-certs to generate such a CA bundle.
    # curlFull is the curl we are looking for.
    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/top-level/all-packages.nix#L3030
    pkgs.curlFull

    pkgs.diffutils
    pkgs.dig
    pkgs.file
    pkgs.findutils
    pkgs.gawk
    pkgs.gnugrep
    pkgs.gnumake
    pkgs.gnused
    pkgs.gnutar
    pkgs.gzip
    pkgs.less
    pkgs.openssh
    pkgs.openssl
    pkgs.patch
    pkgs.perl
    # Install GNU Time
    # This program does not come with a manpage.
    # Instead, it uses GNU Texinfo.
    pkgs.time
    pkgs.unzip
    pkgs.xz
    pkgs.zip
  ];
}
