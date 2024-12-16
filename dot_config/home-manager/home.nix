{ config, pkgs, ... }:

{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.username
  home.username = "louischan";
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.homeDirectory
  home.homeDirectory = "/Users/louischan";

  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.stateVersion
  home.stateVersion = "24.05";

  # https://nixos.wiki/wiki/Unfree_Software
  nixpkgs.config.allowUnfree = true;

  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.home-manager.enable
  programs.home-manager.enable = true;

  # neovim@0.10.2 has a bug with :h i_CTRL-X_CTRL-O
  # This can always be reproduced when I am editing a Go file with gopls enabled.
  # When I type a package identifier, a dot and then i_CTRL-X_CTRL-O, I will see this bug.
  # See https://github.com/neovim/neovim/issues/30688

  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable
  programs.neovim.enable = true;
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.withNodeJs
  programs.neovim.withNodeJs = false;
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.withPython3
  programs.neovim.withPython3 = false;
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.withRuby
  programs.neovim.withRuby = false;
  # Instead of enabling nodejs support in neovim, we just make nodejs available to neovim,
  # for nvim-treesitter to compile parser from grammar.
  programs.neovim.extraPackages = [
    pkgs.nodejs
  ];

  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages
  home.packages = [
    # The following packages replace programs that ship with macOS.
    pkgs.bashInteractive
    pkgs.bzip2
    pkgs.dig
    pkgs.coreutils-prefixed
    # In case you need to curl a website whose TLS certificate is signed by
    # a locally trusted CA, like the one created by mkcert,
    # you need to set SSL_CERT_FILE to point to a full CA bundle.
    # You can use the command macos-ca-certs to generate such a CA bundle.
    (pkgs.curl.override {
      brotliSupport = true;
      gsaslSupport = true;
      http2Support = true;
      # http3Support requires a TLS library supporting QUIC,
      # in which openssl does not support QUIC.
      http3Support = false;
      websocketSupport = true;
      idnSupport = true;
      ldapSupport = true;
      opensslSupport = true;
      pslSupport = true;
      rtmpSupport = true;
      scpSupport = true;
      zlibSupport = true;
      zstdSupport = true;
    })
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
    # Install GNU Time
    # This program does not come with a manpage.
    # Instead, it uses GNU Texinfo.
    pkgs.time
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

    # The REPL of Fennel without readline is very limited.
    # So we install readline for it.
    # See https://fennel-lang.org/setup#adding-readline-support-to-fennel
    # Note that the parenthesis around this is very important.
    # Otherwise, the function is not called and it becomes an item in the list, which is unexpected.
    (pkgs.luajitPackages.fennel.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.readline
        pkgs.luajitPackages.readline
      ];
    }))

    pkgs.ffmpeg
    pkgs.fish
    pkgs.fnlfmt
    pkgs.fzf
    pkgs.gnupg
    pkgs.gopls
    # pprof requires this graph visualization software to generate graphs.
    pkgs.graphviz
    pkgs.hadolint
    pkgs.imagemagick
    pkgs.jq
    pkgs.lua-language-server
    pkgs.mkcert
    pkgs.navi
    # nil the the language server for Nix.
    # See https://github.com/oxalica/nil
    pkgs.nil
    pkgs.nixfmt-rfc-style
    pkgs.nix-direnv
    # nssTools includes a program called certutil,
    # which is required by mkcert to install CA for Firefox.
    pkgs.nssTools
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
    # Taplo is a language server for TOML, and more.
    # See https://taplo.tamasfe.dev/
    pkgs.taplo
    # Install GNU Texinfo to view documentation of GNU software, such as GNU Time.
    pkgs.texinfoInteractive
    pkgs.tlrc
    pkgs.tmux
    # Some parsers like ocamllex and swift requires the tree-sitter executable.
    # So we install it for them.
    pkgs.tree-sitter
    pkgs.typos-lsp
    pkgs.vscode-langservers-extracted
    pkgs.wget
    pkgs.yaml-language-server

    # The following are fonts.
    # The monospace font I use.
    pkgs.source-han-mono
    # CJK fonts
    pkgs.source-han-sans
    pkgs.source-han-serif
  ];
}
