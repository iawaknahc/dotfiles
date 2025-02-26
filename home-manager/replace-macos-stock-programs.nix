{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # The following packages replace programs that ship with macOS.
    bzip2
    (coreutils-prefixed.override {
      # Set minimal to false so that the man pages are installed.
      minimal = false;
      # withOpenssl = !minimal by default. Revert it to false.
      withOpenssl = false;
    })

    # In case you need to curl a website whose TLS certificate is signed by
    # a locally trusted CA, like the one created by mkcert,
    # you need to set SSL_CERT_FILE to point to a full CA bundle.
    # You can use the command macos-ca-certs to generate such a CA bundle.
    # curlFull is the curl we are looking for.
    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/top-level/all-packages.nix#L3030
    curlFull

    diffutils
    dig
    file
    findutils
    gawk
    gnugrep
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
