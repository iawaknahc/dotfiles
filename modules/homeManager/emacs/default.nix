{
  config,
  pkgs,
  lib,
  ...
}:
{
  assertions = [
    {
      assertion = (lib.versions.majorMinor config.programs.emacs.package.version) == "30.2";
      message = "lua-mode should be built-in when Emacs > 30.2";
    }
  ];

  programs.emacs.enable = true;
  programs.emacs.package =
    # It has to be Emacs Macport otherwise the scrollbar has a non-customizable white background color.
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs30-macport else pkgs.emacs30-pgtk;

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
    just-ts-mode = self.melpaPackages.just-ts-mode;
    nushell-ts-mode = self.melpaPackages.nushell-ts-mode;

    # melpaStablePackages
    apheleia = self.melpaStablePackages.apheleia;
    corfu-prescient = self.melpaStablePackages.corfu-prescient;
    evil = self.melpaStablePackages.evil;
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
    ultra-scroll = self.melpaStablePackages.ultra-scroll;
    vertico-prescient = self.melpaStablePackages.vertico-prescient;
    # FIXME: wgrep is available on elpaPackages as well, but it cannot build due to missing dash at test time.
    # I tried `dontCheck = true` but it did not work.
    wgrep = self.melpaStablePackages.wgrep;
    zig-ts-mode = self.melpaStablePackages.zig-ts-mode;

    # elpaPackages
    cape = self.elpaPackages.cape;
    compat = self.elpaPackages.compat;
    consult = self.elpaPackages.consult;
    corfu = self.elpaPackages.corfu;
    diff-hl = self.elpaPackages.diff-hl;
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
    # llama is a dependency of magit.
    llama = self.nongnuPackages.llama;
    # `cond-let` is a dependency of magit.
    cond-let = self.nongnuPackages.cond-let;
    magit = self.nongnuPackages.magit;
    # magit-section is a dependency of magit.
    magit-section = self.nongnuPackages.magit-section;
    markdown-mode = self.nongnuPackages.markdown-mode;
    # with-with-editor is a dependency of magit.
    with-editor = self.nongnuPackages.with-editor;
  };
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      # Theme
      catppuccin-theme

      # Email
      mu4e

      # Scrolling
      ultra-scroll

      # Lisp
      rainbow-delimiters

      # Evil
      evil

      # Hyperbole
      hyperbole

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

      # FIXME: Switch to grep-edit-mode in Emacs 31.
      wgrep

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

      # Modes
      beancount
      fennel-mode
      fish-mode
      just-ts-mode
      # markdown-ts-mode is broken. Its replacement is available on Emacs 31.
      markdown-mode
      nix-ts-mode
      nushell-ts-mode
      zig-ts-mode
    ];
  programs.emacs.extraConfig = ''
    (setq mu4e-attachment-dir "${config.home.homeDirectory}/Downloads")
  '';
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;
  home.file.".emacs.d/lisp" = {
    source = ./emacs.d/lisp;
    # recursive is needed because .emacs.d/lisp may contain generated files.
    recursive = true;
  };
  home.file.".emacs.d/templates".source = ./emacs.d/templates.el;
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        vobject
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
}
