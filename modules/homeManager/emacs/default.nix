{
  config,
  pkgs,
  lib,
  ...
}:
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

  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs31-pgtk;

  # overrides is the documented way to ensure a package is from a specific package set.
  # See https://nixos.org/manual/nixpkgs/stable/#sec-emacs-config
  #
  # The convention here is whenever we add a package,
  # we must specify its package set, and its dependencies' package set.
  programs.emacs.overrides = self: super: {
    # manualPackages
    mu4e = self.manualPackages.mu4e;

    # melpaPackages
    # FIXME: ccatppuccin-theme from melpaStablePackages is too old to have ccatppuccin-reload.
    catppuccin-theme = self.melpaPackages.catppuccin-theme;
    # The latest release on NonGNU ELPA is 1.15.0 which was released in 2024.
    # The latest release on MELPA stable is 1.14.2 which is even older.
    evil = self.melpaPackages.evil;
    just-ts-mode = self.melpaPackages.just-ts-mode;
    nushell-ts-mode = self.melpaPackages.nushell-ts-mode;

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
    osm = self.melpaStablePackages.osm;
    prescient = self.melpaStablePackages.prescient;
    rainbow-delimiters = self.melpaStablePackages.rainbow-delimiters;
    # `s` is a dependency of vulpea.
    s = self.melpaStablePackages.s;
    ultra-scroll = self.melpaStablePackages.ultra-scroll;
    vertico-prescient = self.melpaStablePackages.vertico-prescient;
    vui = self.melpaStablePackages.vui;
    vulpea = self.melpaStablePackages.vulpea;
    vulpea-ui = self.melpaStablePackages.vulpea-ui;
    zig-ts-mode = self.melpaStablePackages.zig-ts-mode;

    # elpaPackages
    cape = self.elpaPackages.cape;
    compat = self.elpaPackages.compat;
    consult = self.elpaPackages.consult;
    corfu = self.elpaPackages.corfu;
    diff-hl = self.elpaPackages.diff-hl;
    # dash is a dependency of vulpea.
    dash = self.elpaPackages.dash;
    eglot = self.elpaPackages.eglot;
    eldoc = self.elpaPackages.eldoc;
    embark = self.elpaPackages.embark;
    embark-consult = self.elpaPackages.embark-consult;
    flymake = self.elpaPackages.flymake;
    jsonrpc = self.elpaPackages.jsonrpc;
    marginalia = self.elpaPackages.marginalia;
    orderless = self.elpaPackages.orderless;
    org = self.elpaPackages.org;
    project = self.elpaPackages.project;
    seq = self.elpaPackages.seq;
    tempel = self.elpaPackages.tempel;
    track-changes = self.elpaPackages.track-changes;
    tramp = self.elpaPackages.tramp;
    vertico = self.elpaPackages.vertico;
    xref = self.elpaPackages.xref;
    # transient is a dependency of magit.
    transient = self.elpaPackages.transient;

    # nongnuPackages
    beancount = self.nongnuPackages.beancount;
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

      # Email
      mu4e

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

      # Install the latest version of builtin packages that I really care about.
      # Note that the following list is not exhaustive.
      # There are way more bundled packages that are also available on GNU ELPA.
      compat
      eglot
      eldoc
      flymake
      jsonrpc
      org
      project
      seq
      track-changes
      tramp
      xref

      # Notes
      vulpea
      vulpea-ui
      osm

      # Modes
      beancount
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
  home.file.".emacs.d/user-lisp" = {
    source = ./emacs.d/user-lisp;
    # recursive is needed because .emacs.d/user-lisp may contain generated files.
    recursive = true;
  };
  home.file.".emacs.d/lisp" = {
    source = ./emacs.d/lisp;
    # recursive is needed because .emacs.d/lisp may contain generated files.
    recursive = true;
  };
  home.file.".emacs.d/lisp/init-exec-path-from-shell.el".text =
    let
      pairs = (lib.attrsets.attrsToList config.home.sessionVariables);
      quoted = (builtins.map ({ name, ... }: ''"${name}"'') pairs);
      vars = lib.strings.join " " quoted;
    in
    ''
      ;;; init-exec-path-from-shell.el --- init-exec-path-from-shell.el -*- lexical-binding: t -*-
      ;;; Commentary:
      ;;; Code:

      (setq exec-path-from-shell-variables (list "NIX_PROFILES" "NIX_SSL_CERT_FILE" "NIX_USER_PROFILE_DIR" "PATH" "SSH_AUTH_SOCK" ${vars}))
      (when (memq window-system '(ns))
        (exec-path-from-shell-initialize))

      (provide 'init-exec-path-from-shell)
      ;;; init-exec-path-from-shell.el ends here
    '';
  home.file.".emacs.d/templates".source = ./emacs.d/templates.el;

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
