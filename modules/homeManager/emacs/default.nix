{
  config,
  pkgs,
  lib,
  ...
}:
let
  ghostel = pkgs.emacsPackages.manualPackages.ghostel;
in
{
  assertions = [
    {
      assertion = pkgs.emacsPackages.melpaStablePackages.vulpea.version == "2.7.0";
      message = "vulpea has a newer version than 2.7.0. Read the changelog and plan the upgrade.";
    }
  ];

  home.packages = with pkgs; [
    # fswatch is required by vulpea
    fswatch
  ];

  # Official shell integration snippets
  # See https://dakra.github.io/ghostel/#shell-integration
  # The modification is changing from referencing EMACS_GHOSTEL_PATH to Nix store path.
  # We have to do this because Nushell expects to have a parse-time constant path.
  programs.bash.initExtra = ''
    [[ "''${INSIDE_EMACS%%,*}" = 'ghostel' ]] && source "${ghostel}/share/emacs/site-lisp/elpa/ghostel-${ghostel.version}/etc/shell/ghostel.bash"
  '';
  programs.zsh.initContent = ''
    [[ "''${''${INSIDE_EMACS-}%%,*}" = 'ghostel' ]] && source "${ghostel}/share/emacs/site-lisp/elpa/ghostel-${ghostel.version}/etc/shell/ghostel.zsh"
  '';
  programs.fish.interactiveShellInit = ''
    string match -qr '^ghostel(,|$)' -- "$INSIDE_EMACS"; and source "${ghostel}/share/emacs/site-lisp/elpa/ghostel-${ghostel.version}/etc/shell/ghostel.fish"
  '';
  programs.nushell.extraConfig = ''
    source "${ghostel}/share/emacs/site-lisp/elpa/ghostel-${ghostel.version}/etc/shell/ghostel.nu"
  '';

  programs.emacs.enable = true;
  programs.emacs.package =
    # Use NS build on macOS, and PGTK build on Linux.
    if pkgs.stdenv.hostPlatform.isLinux then pkgs.emacs31-pgtk else pkgs.emacs31;

  # overrides is the documented way to ensure a package is from a specific package set.
  # See https://nixos.org/manual/nixpkgs/stable/#sec-emacs-config
  #
  # The convention here is whenever we add a package,
  # we must specify its package set, and its dependencies' package set.
  programs.emacs.overrides = self: super: {
    # manualPackages
    mu4e = self.manualPackages.mu4e;
    ghostel = self.manualPackages.ghostel;

    # melpaPackages
    catppuccin-theme = self.melpaPackages.catppuccin-theme;
    # The latest release on NonGNU ELPA is 1.15.0 which was released in 2024.
    # The latest release on MELPA stable is 1.14.2 which is even older.
    evil = self.melpaPackages.evil.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ [
        # evil-search: show match count when using isearch
        # See https://github.com/emacs-evil/evil/pull/1992
        ./evil-pr-1992.patch
        # evil-search: respect lazy-highlight-cleanup in evil-flash-hook
        # This keeps the search results highlighted when lazy-highlight-cleanup is nil.
        ./evil-respect-lazy-highlight-cleanup.patch
      ];
    });
    just-ts-mode = self.melpaPackages.just-ts-mode;
    nushell-ts-mode = self.melpaPackages.nushell-ts-mode;
    # diff-hl has a serious bug that always set left-margin-width to 1.
    # See https://github.com/dgutov/diff-hl/issues/289
    # As of 2026-09-18, the latest release was 1.10.0 on 2024-08-03
    # So we have to use the version on MELPA.
    diff-hl = self.melpaPackages.diff-hl;
    org-mime = self.melpaPackages.org-mime;

    # melpaStablePackages
    apheleia = self.melpaStablePackages.apheleia;
    corfu-prescient = self.melpaStablePackages.corfu-prescient;
    fennel-mode = self.melpaStablePackages.fennel-mode;
    fish-mode = self.melpaStablePackages.fish-mode;
    flymake-quickdef = self.melpaStablePackages.flymake-quickdef;
    # Hyperbole is also available on elpaPackages.
    # But it is broken there.
    # The one from melpaStablePackages has fixes applied.
    # See https://github.com/NixOS/nixpkgs/blob/26.05/pkgs/applications/editors/emacs/elisp-packages/melpa-packages.nix#L1325
    hyperbole = self.melpaStablePackages.hyperbole;
    # goto-chg is a dependency of evil.
    goto-chg = self.melpaStablePackages.goto-chg;
    nix-ts-mode = self.melpaStablePackages.nix-ts-mode;
    olivetti = self.melpaStablePackages.olivetti;
    prescient = self.melpaStablePackages.prescient;
    rainbow-delimiters = self.melpaStablePackages.rainbow-delimiters;
    # `s` is a dependency of vulpea.
    s = self.melpaStablePackages.s;
    simple-httpd = self.melpaStablePackages.simple-httpd;
    ultra-scroll = self.melpaStablePackages.ultra-scroll;
    vertico-prescient = self.melpaStablePackages.vertico-prescient;
    vui = self.melpaStablePackages.vui;
    vulpea = self.melpaStablePackages.vulpea;
    vulpea-ui = self.melpaStablePackages.vulpea-ui;
    zig-ts-mode = self.melpaStablePackages.zig-ts-mode;

    # elpaPackages
    # Setting to null drop the packages from dependents' requirements.
    # This is not documented but used in upstream.
    # See https://github.com/NixOS/nixpkgs/blob/26.05/pkgs/applications/editors/emacs/elisp-packages/elpa-common-overrides.nix#L75
    cape = self.elpaPackages.cape;
    compat = null;
    consult = self.elpaPackages.consult;
    corfu = self.elpaPackages.corfu;
    # dash is a dependency of vulpea.
    dash = self.elpaPackages.dash;
    denote = self.elpaPackages.denote;
    eglot = null;
    eldoc = null;
    embark = self.elpaPackages.embark;
    embark-consult = self.elpaPackages.embark-consult;
    flymake = null;
    jsonrpc = null;
    marginalia = self.elpaPackages.marginalia;
    orderless = self.elpaPackages.orderless;
    org = self.elpaPackages.org;
    project = null;
    seq = null;
    tempel = self.elpaPackages.tempel;
    track-changes = null;
    tramp = null;
    vertico = self.elpaPackages.vertico;
    xref = null;
    # transient is a dependency of magit.
    transient = self.elpaPackages.transient;
    vlf = self.elpaPackages.vlf;

    # nongnuPackages
    exec-path-from-shell = self.nongnuPackages.exec-path-from-shell;
    # emacsql is a dependency of vulpea.
    emacsql = self.nongnuPackages.emacsql;
    # llama is a dependency of magit.
    llama = self.nongnuPackages.llama;
    # `cond-let` is a dependency of magit.
    cond-let = self.nongnuPackages.cond-let;
    magit = self.nongnuPackages.magit;
    # magit-section is a dependency of magit.
    magit-section = self.nongnuPackages.magit-section;
    # with-with-editor is a dependency of magit.
    with-editor = self.nongnuPackages.with-editor;
  };
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      # Fix environment variables
      exec-path-from-shell

      # Theme
      catppuccin-theme

      # Terminal emulator
      ghostel

      # Email
      mu4e
      org-mime

      # Evil
      evil

      # Snippet
      tempel

      # Reading
      olivetti

      # Completion
      corfu
      cape
      vertico
      orderless
      marginalia
      prescient
      corfu-prescient
      vertico-prescient
      embark
      consult
      embark-consult

      # Tree-sitter
      # Originally, it was `treesit-grammars.with-all-grammars`.
      # But the tsx parser built by it does not contain the expected symbol `tree_sitter_tsx`.
      # Instead, it contains `tree_sitter_typescript`.
      # This problem was surfaced by the warning emitted by treesit.el during the startup of Emacs.
      #
      # I did not go into details on why that happen.
      # I know that Neovim works fine in this case,
      # so I work around this by using the parsers of nvim-treesitter.
      #
      # Since treesit-grammars does not expose its logic for override[1],
      # I need to duplicate its logic here, and
      # replace `pkgs.tree-sitter-grammars.allGrammars` with
      # `pkgs.vimPlugins.nvim-treesitter.allGrammars`.
      #
      # [1]: https://github.com/NixOS/nixpkgs/blob/26.05/pkgs/applications/editors/emacs/elisp-packages/manual-packages/treesit-grammars/package.nix
      (
        let
          libExt = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
          grammarToAttrSet = drv: {
            name = "lib/lib${
              lib.strings.replaceStrings [ "_" ] [ "-" ] (
                lib.strings.removeSuffix "-grammar" (lib.strings.getName drv)
              )
            }${libExt}";
            path = "${drv}/parser";
          };

          grammarPackage = grammars: pkgs.linkFarm "emacs-treesit-grammars" (map grammarToAttrSet grammars);

          with-all-grammars = grammarPackage pkgs.vimPlugins.nvim-treesitter.allGrammars;
        in
        with-all-grammars
      )

      # VC
      diff-hl
      magit

      # Auto-format on save
      apheleia

      # Define Flymake backends
      flymake-quickdef

      # Install the latest version of Org
      org

      # Very Large File
      vlf

      # Notes
      vulpea
      vulpea-ui

      # Organizing files
      denote

      # HTTP server
      simple-httpd

      # vCard
      (emacsPackages.callPackage (import ../../../packages/emacs-ecard.nix) { })

      # Modes
      fennel-mode
      fish-mode
      just-ts-mode
      nix-ts-mode
      nushell-ts-mode
      zig-ts-mode
    ];
  programs.emacs.extraConfig = ''
    (setq mu4e-attachment-dir "${config.home.homeDirectory}/Downloads")
  '';
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;

  # We used to use recursive=true to copy the whole directory.
  # But that will cause the resolved path to a .el file changes on every switch.
  # By generating each file one by one, the resolved path will change only when
  # its contents change between the switches.
  # When the resolved path and the contents of the file stays stable,
  # Emacs will skip native-compile the .el file.
  # This results in a greatly reduced time of the first launch after a switch.
  imports = [
    {
      home.file =
        lib.mapAttrs'
          (
            filename: _:
            lib.nameValuePair ".emacs.d/user-lisp/${filename}" {
              source = ./emacs.d/user-lisp + "/${filename}";
              # The .el is a file in Nix store, so it has a 1970 mtime.
              # Emacs uses mtime to determine whether to byte-compile a .el into .elc.
              # Thus, it never byte-compile a .el file.
              # To force byte-compilation, we remove the .elc file.
              onChange = ''rm -f "$HOME/.emacs.d/user-lisp/${filename}c"'';
            }
          )
          (
            lib.filterAttrs (filename: filetype: filetype == "regular" && lib.hasSuffix ".el" filename) (
              builtins.readDir ./emacs.d/user-lisp
            )
          );
    }
  ];

  home.file.".emacs.d/maplibre".source = ./emacs.d/maplibre;
  home.file.".emacs.d/user-lisp/init-exec-path-from-shell.el".text =
    let
      pairs = (lib.attrsets.attrsToList config.home.sessionVariables);
      quoted = (builtins.map ({ name, ... }: ''"${name}"'') pairs);
      vars = lib.strings.join " " quoted;
    in
    ''
      ;;; init-exec-path-from-shell.el --- init-exec-path-from-shell.el -*- lexical-binding: t -*-
      ;;; Commentary:
      ;;; Code:

      (defvar exec-path-from-shell-variables)
      (declare-function exec-path-from-shell-initialize "exec-path-from-shell")

      (setq exec-path-from-shell-variables (list "NIX_PROFILES" "NIX_SSL_CERT_FILE" "NIX_USER_PROFILE_DIR" "PATH" "SSH_AUTH_SOCK" ${vars}))
      (when (memq window-system '(ns))
        (exec-path-from-shell-initialize))

      (provide 'init-exec-path-from-shell)
      ;;; init-exec-path-from-shell.el ends here
    '';
  # Show Org agenda items in calendar buffers.
  home.file.".emacs.d/diary".text = ''
    %%(org-diary)
  '';

  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        rassumfrassum

        (config.mypython.pythonPackages.buildPythonPackage {
          pname = "my_rass";
          version = "1.0.0";
          pyproject = true;
          build-system = [ setuptools ];
          src = ./my_rass;
        })
      ]
    )
  ];
  xdg.configFile."rassumfrassum" = {
    source = ./rassumfrassum;
    recursive = true;
  };

  sops.secrets."emacs_osm_maptiler/api_key" = { };
  sops.templates.".authinfo" = {
    path = "${config.home.homeDirectory}/.authinfo";
    content = ''
      machine maptiler.com login apikey password ${config.sops.placeholder."emacs_osm_maptiler/api_key"}
    '';
  };
}
