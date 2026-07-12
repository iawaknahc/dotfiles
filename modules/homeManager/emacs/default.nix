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
    {
      assertion = (lib.versions.majorMinor config.programs.emacs.package.version) == "30.2";
      message = "markdown-ts-mode should be built-in when Emacs > 30.2";
    }
  ];

  programs.emacs.enable = true;
  programs.emacs.package =
    # It has to be Emacs Macport otherwise the scrollbar has a non-customizable white background color.
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs30-macport else pkgs.emacs30-pgtk;
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      catppuccin-theme
      mu4e
      ultra-scroll
      evil

      treesit-grammars.with-all-grammars

      fish-mode
      just-ts-mode
      lua-mode # lua-ts-mode is built-in.
      markdown-mode
      markdown-ts-mode
      nix-ts-mode
      nushell-ts-mode
      typescript-mode # typescript-ts-mode is built-in.
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
