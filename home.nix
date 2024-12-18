{
  pkgs,
  nixpkgs,
  ...
}:

{
  # This causes home-manager to include NIX_PATH in its shell script.
  # My shell sources that shell script and have NIX_PATH properly set.
  #
  # nix repl -f <nixpkgs> now correctly loads this nixpkgs.
  # To verify this claim, we should
  # 1. sudo nix-channel --remove nixpkgs
  # 2. NIX_PATH="" nix repl -f <nixpkgs>
  # 2 should say nixpkgs is not found.
  # https://nix-community.github.io/home-manager/options.xhtml#opt-nix.nixPath
  nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];

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
    pkgs.babelfish
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

  # POSIX-ish shells
  home.file.".profile" = {
    enable = true;
    source = ./.profile;
  };
  home.file.".bashrc" = {
    enable = true;
    source = ./.bashrc;
  };
  home.file.".bash_profile" = {
    enable = true;
    source = ./.bash_profile;
  };
  home.file.".zshrc" = {
    enable = true;
    source = ./.zshrc;
  };
  home.file.".zprofile" = {
    enable = true;
    source = ./.zprofile;
  };
  home.file.".zlogin" = {
    enable = true;
    source = ./.zlogin;
  };
  home.file.".zlogout" = {
    enable = true;
    source = ./.zlogout;
  };
  home.file.".zshenv" = {
    enable = true;
    source = ./.zshenv;
  };

  # vim
  home.file.".vimrc" = {
    enable = true;
    source = ./.vimrc;
  };

  # tmux
  home.file.".tmux.conf" = {
    enable = true;
    source = ./.tmux.conf;
  };

  # stylua
  home.file.".stylua.toml" = {
    enable = true;
    source = ./.stylua.toml;
  };

  # GNU info
  home.file.".infokey" = {
    enable = true;
    source = ./.infokey;
  };

  # .local/bin
  home.file.".local/bin" = {
    enable = true;
    recursive = true;
    source = ./.local/bin;
  };

  # .local/share/navi/cheats/
  home.file.".local/share/navi/cheats" = {
    enable = true;
    recursive = true;
    source = ./.local/share/navi/cheats;
  };

  # .config/alacritty/
  xdg.configFile."alacritty" = {
    enable = true;
    recursive = true;
    source = ./.config/alacritty;
  };

  # .config/bat/
  xdg.configFile."bat" = {
    enable = true;
    recursive = true;
    source = ./.config/bat;
  };

  # .config/delta/
  xdg.configFile."delta" = {
    enable = true;
    recursive = true;
    source = ./.config/delta;
  };

  # .config/fd/
  xdg.configFile."fd" = {
    enable = true;
    recursive = true;
    source = ./.config/fd;
  };

  # .config/fzf/
  xdg.configFile."fzf" = {
    enable = true;
    recursive = true;
    source = ./.config/fzf;
  };

  # .config/git/
  xdg.configFile."git" = {
    enable = true;
    recursive = true;
    source = ./.config/git;
  };

  # .config/kitty/
  xdg.configFile."kitty" = {
    enable = true;
    recursive = true;
    source = ./.config/kitty;
  };

  # .config/nix/
  # home-manager actually cannot bootstrap itself in a flake-based setup.
  # When ~/.config/nix/nix.conf is absent, extra-experimental-features = nix-command flakes is absent.
  # The absence makes home-manager fail to run, thus nix.conf is not written.
  # The documentation says invoking home-manager with --extra-experimental-features = nix-command flakes should do the job.
  # But somehow the flag is not propagated correctly.
  #
  # To work around this, we have to edit /etc/nix/nix.conf to enable nix-command and flakes.
  # So that ~/.config/nix/nix.conf is written once.
  # After that we can revert the changes in /etc/nix/nix.conf
  xdg.configFile."nix" = {
    enable = true;
    recursive = true;
    source = ./.config/nix;
  };
}
