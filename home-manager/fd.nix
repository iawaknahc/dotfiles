{ ... }:
{
  programs.fd.enable = true;
  programs.fd.hidden = true;
  programs.fd.ignores = [
    # Git
    ".git/"

    # NodeJS ecosystem
    "node_modules/"

    # macOS
    "Library/"
    "Volumes/"
    "Applications/"

    # A heuristic to ignore GOPATH
    "go/"
    # A heuristic to ignore a local copy of NixOS/nixpkgs
    "nixpkgs/"

    # Like ~/.android/cache ~/.bundle/cache
    "cache/"
    # Like ~/.gradle/caches
    "caches/"

    # XDG_CACHE_HOME
    ".cache/"

    ".local/share/android/"
    ".rustup/toolchains/"
    ".weasis/cache-*/"
  ];
}
