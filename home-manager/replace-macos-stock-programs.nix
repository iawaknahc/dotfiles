{ pkgs, ... }:
let
  wrappers = import ./wrappers.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # The following packages replace programs that ship with macOS.
    bzip2
    wrappers.coreutils_

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
