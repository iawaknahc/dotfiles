{ config, pkgs, ... }:

{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.username
  home.username = "louischan";
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.homeDirectory
  home.homeDirectory = "/Users/louischan";

  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.stateVersion
  home.stateVersion = "24.05";

  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.home-manager.enable
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/Unfree_Software
  nixpkgs.config.allowUnfree = true;

  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages
  home.packages = [
    # The following packages replace programs that ship with macOS.
    pkgs.bashInteractive
    pkgs.bzip2
    pkgs.dig
    pkgs.coreutils-prefixed
    pkgs.curl
    pkgs.diffutils
    pkgs.file
    pkgs.findutils
    pkgs.gawk
    pkgs.git
    pkgs.gnugrep
    pkgs.gnumake
    pkgs.gnused
    pkgs.gnutar
    pkgs.gzip
    pkgs.less
    pkgs.ncurses
    pkgs.openssh
    pkgs.openssl
    pkgs.patch
    pkgs.perl
    pkgs.unzip
    pkgs.vim
    pkgs.xz
    pkgs.zip
    pkgs.zsh

    # The following packages are not present in stock macOS.
    pkgs._1password-cli
    pkgs.bash-completion
    pkgs.bfs
    pkgs.blackbox
    pkgs.chezmoi
    pkgs.delve
    pkgs.direnv
    pkgs.exiftool
    pkgs.eza
    pkgs.fastmod
    pkgs.fd
    pkgs.ffmpeg
    pkgs.fish
    pkgs.fzf
    pkgs.gnupg
    pkgs.gopls
    pkgs.hadolint
    pkgs.jq
    pkgs.lua-language-server
    pkgs.neovim
    pkgs.nix-direnv
    pkgs.nodePackages.bash-language-server
    pkgs.nodePackages.graphql-language-service-cli
    pkgs.nodePackages.typescript-language-server
    pkgs.pinentry_mac
    pkgs.pinentry-tty
    pkgs.prettierd
    pkgs.pyright
    # qrencode generates QR code locally.
    # Ideal for sensitive contents.
    pkgs.qrencode
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.stylua
    pkgs.tailwindcss-language-server
    pkgs.tmux
    pkgs.vscode-langservers-extracted
    pkgs.wget
    pkgs.yaml-language-server
  ];
}
