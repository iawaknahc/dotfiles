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

      # Flymake
      flycheck

      # Tree-sitter
      treesit-grammars.with-all-grammars

      # VC
      diff-hl

      # Auto-format on save
      apheleia

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
}
