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
      goto-chg
      evil

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

      # Auto-format on save
      apheleia

      # Define Flymake backends
      flymake-quickdef

      # FIXME: Switch to grep-edit-mode in Emacs 31.
      wgrep

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
}
