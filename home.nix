{
  pkgs,
  nixpkgs,
  lib,
  config,
  ...
}:
let
  wrapProgramForPackage = (
    package: postInstall:
    package.overrideAttrs (prev: {
      nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postInstall = (prev.postInstall or "") + postInstall;
    })
  );
in
# Since we have to generate xdg.configFile dynamically for Fennel compilation in Nvim,
# we need to use mkMerge to work around { xdg.configFile = { ... } } and { xdg.configFile."a" = { ... } }
# cannot appear in the same attrset lexically.
lib.mkMerge [
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

    # Set LANG.
    # LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
    home.language.base = "en_US.UTF-8";

    # https://nixos.wiki/wiki/Unfree_Software
    nixpkgs.config.allowUnfree = true;

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.home-manager.enable
    programs.home-manager.enable = true;

    # neovim@0.10.2 has a bug with :h i_CTRL-X_CTRL-O
    # This can always be reproduced when I am editing a Go file with gopls enabled.
    # When I type a package identifier, a dot and then i_CTRL-X_CTRL-O, I will see this bug.
    # See https://github.com/neovim/neovim/issues/30688

    # https://nix-community.github.io/home-manager/options.xhtml#opt-home.packages
    home.packages = [
      # The following packages replace programs that ship with macOS.
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
      pkgs.bfs
      pkgs.blackbox
      pkgs.delve
      pkgs.exiftool
      pkgs.eza
      pkgs.fastmod
      pkgs.ffmpeg
      pkgs.fish
      pkgs.fnlfmt
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
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.stylua
      pkgs.tailwindcss-language-server
      # Taplo is a language server for TOML, and more.
      # See https://taplo.tamasfe.dev/
      pkgs.taplo
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

    # .gpg
    home.activation.createGPGHomeDir =
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
        ''
          run mkdir -m700 -p $VERBOSE_ARG ${
            pkgs.lib.strings.escapeShellArgs [ "${config.programs.gpg.homedir}" ]
          }
        '';
    home.file."${config.programs.gpg.homedir}/gpg.conf" = {
      enable = true;
      source = ./.gnupg/gpg.conf;
    };
    home.file."${config.programs.gpg.homedir}/dirmngr.conf" = {
      enable = true;
      source = ./.gnupg/dirmngr.conf;
    };
    home.file."${config.programs.gpg.homedir}/gpg-agent.conf" = {
      enable = true;
      # pinentry-program accepts only absolute path.
      # See https://dev.gnupg.org/T4588
      text = ''
        pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
      '';
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

    # .config/fish/
    # When we were still using chezmoi, we use exact_conf.d/.gitkeep
    # to make sure extra files in ~/.config/fish/conf.d/ are removed.
    # That behavior can be replicated with home.activation.
    xdg.configFile."fish" = {
      enable = true;
      recursive = true;
      source = ./.config/fish;
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

    # .config/navi
    # navi is known to write log files to XDG_CONFIG_HOME
    # See https://github.com/denisidoro/navi/blob/master/docs/navi_config.md#logging
    xdg.configFile."navi" = {
      enable = true;
      recursive = true;
      source = ./.config/navi;
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

    # .config/pip
    xdg.configFile."pip" = {
      enable = true;
      recursive = true;
      source = ./.config/pip;
    };

    # .config/wezterm
    xdg.configFile."wezterm" = {
      enable = true;
      recursive = true;
      source = ./.config/wezterm;
    };
  }

  # shell aliases for bash, zsh, and fish
  {
    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      view = "nvim -R";
      vimdiff = "nvim -d";
    };
  }

  # bash
  # bash -il reads the FIRST file in this order: .bash_profile .bash_login .profile
  # bash -i reads .bashrc
  {
    programs.bash.enable = true;
    home.packages = [ pkgs.bash-completion ];
    programs.bash.bashrcExtra = ''
      if shopt -q login_shell; then
        echo "login shell: true"
      else
        echo "login shell: false"
      fi
      echo "sourcing $BASH_SOURCE"

      . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

      # Turn on vi mode
      set -o vi

      # Configure prompt
      export PS1="[$SHLVL] \$ "
      export PS2='> '
    '';
    programs.bash.profileExtra = ''
      echo "sourcing .profile"
    '';
  }

  # direnv
  {
    # Install the binary direnv.
    programs.direnv.enable = true;
    # Install nix-direnv to ~/.config/direnv/lib/hm-nix-direnv.sh
    programs.direnv.nix-direnv.enable = true;
  }

  # fd
  {
    programs.fd.enable = true;
    programs.fd.ignores = [
      # Ignore .git even -H is used.
      ".git/"
    ];
  }

  # fzf
  {
    programs.fzf.enable = true;
    programs.fzf.defaultCommand = "true";
    programs.fzf.defaultOptions = [
      "--with-shell='sh -c'"
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
    programs.fzf.enableBashIntegration = false;
  }

  # ripgrep
  {
    programs.ripgrep.enable = true;
    programs.ripgrep.arguments = [
      # Search hidden files by default.
      "--hidden"
      # Ignore .git
      "--glob=!.git/"
    ];
  }

  # nvim
  {
    programs.neovim.enable = true;
    home.sessionVariables = lib.mkIf config.programs.neovim.enable {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };
    programs.neovim.withNodeJs = false;
    programs.neovim.withPython3 = false;
    programs.neovim.withRuby = false;
    # Instead of enabling nodejs support in neovim, we just make nodejs available to neovim,
    # for nvim-treesitter to compile parser from grammar.
    programs.neovim.extraPackages = [
      pkgs.nodejs
    ];
    xdg.configFile."nvim/init.lua" = {
      enable = true;
      source = ./.config/nvim/init.lua;
    };
    xdg.configFile."nvim/colors" = {
      enable = true;
      recursive = true;
      source = ./.config/nvim/colors;
    };
    xdg.configFile."nvim/lua" = {
      enable = true;
      recursive = true;
      source = ./.config/nvim/lua;
    };
  }

  (
    let
      # The REPL of Fennel without readline is very limited.
      # So we install readline for it.
      # See https://fennel-lang.org/setup#adding-readline-support-to-fennel
      # Note that the parenthesis around this is very important.
      # Otherwise, the function is not called and it becomes an item in the list, which is unexpected.
      fennel = (
        pkgs.luajitPackages.fennel.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [
            pkgs.readline
            pkgs.luajitPackages.readline
          ];
        })
      );
    in
    {
      home.packages = [ fennel ];
      xdg.configFile =
        let
          nvimFennelDir = ./.config/nvim/fnl;
          nvimFennelFileList = pkgs.lib.fileset.toList (pkgs.lib.fileset.maybeMissing nvimFennelDir);
        in
        pkgs.lib.pipe nvimFennelFileList [
          (builtins.map (
            path:
            let
              relativePathString = pkgs.lib.strings.removePrefix ((builtins.toString nvimFennelDir) + "/") (
                builtins.toString path
              );
              target = (pkgs.lib.strings.removeSuffix ".fnl" relativePathString) + ".lua";
              compiledSourceCode = builtins.readFile "${pkgs.runCommand "fennel" { } ''
                ${fennel}/bin/fennel --compile ${path} > $out
              ''}";
            in
            {
              "nvim/lua/${target}" = {
                enable = true;
                text = compiledSourceCode;
              };
            }

          ))
          pkgs.lib.attrsets.mergeAttrsList
        ];
    }
  )

  # tlrc
  # TLRC_CONFIG was implemented but not released yet.
  # So we need to wrap it and prepend --config
  # https://github.com/tldr-pages/tlrc/issues/89
  {
    home.packages = [
      (wrapProgramForPackage pkgs.tlrc ''
        wrapProgram $out/bin/tldr \
          --add-flags "--config ~/.config/tlrc/config.toml"
      '')
    ];
    xdg.configFile."tlrc" = {
      enable = true;
      recursive = true;
      source = ./.config/tlrc;
    };
  }

  # Scripts written by me.
  {
    home.packages = builtins.map (
      path:
      let
        basename = builtins.baseNameOf (builtins.toString path);
        text = builtins.readFile path;
      in
      (pkgs.writeScriptBin basename text)
    ) (pkgs.lib.fileset.toList (pkgs.lib.fileset.maybeMissing ./.local/bin));
  }

  # iTerm
  # iTerm does not set TERMINFO automatically, so we help it here.
  # Note that this is written in sh.
  # Fish shell sources hm-session-vars.sh with babelfish.
  {
    home.sessionVariablesExtra = ''
      if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        if [ -d "/Applications/iTerm.app/Contents/Resources/terminfo" ]; then
          export TERMINFO="/Applications/iTerm.app/Contents/Resources/terminfo"
        fi
      fi
    '';
  }

  # Android SDK
  {
    home.sessionVariablesExtra = ''
      if [ -d "$HOME/Library/Android/sdk" ]; then
        # ANDROID_SDK_ROOT is deprecated
        # https://developer.android.com/tools/variables
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        export PATH="$PATH:$ANDROID_HOME/tools"
        export PATH="$PATH:$ANDROID_HOME/tools/bin"
        # A binary sqlite3 lives here. So we want the binary provided by Android appear
        # at the end in PATH.
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
      fi
    '';
  }

  # Flutter SDK
  {
    home.sessionVariablesExtra = ''
      if [ -d "$HOME/flutter" ]; then
        export FLUTTER_ROOT="$HOME/flutter"
        # Make flutter available
        export PATH="$HOME/flutter/bin:$PATH"
        # Make the executables of embedded dark-sdk, say dartfmt, available
        export PATH="$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"
        # Make executables installed with `flutter packages pub global activate` available
        # Notably, we want to run `flutter packages pub global activate dart_language_server`
        export PATH="$HOME/flutter/.pub-cache/bin:$PATH"
      fi
    '';
  }

  # Google Cloud SDK
  {
    home.sessionVariablesExtra = ''
      if [ -d "$HOME/google-cloud-sdk" ]; then
        # If you have read the source code of "$HOME/google-cloud-sdk/path.bash.inc",
        # you can see that all it does is add google-cloud-sdk/bin to PATH.
        # So we do that ourselves here.
        export PATH="$HOME/google-cloud-sdk/bin:$PATH"
      fi
    '';
  }

  # GNU Info
  # The module sets home.extraOutputsToInstall so it is better to use it,
  # than to installing the package directly.
  {
    programs.info.enable = true;
  }
]
