{ pkgs, ... }:
{
  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs-nox;
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      catppuccin-theme

      goto-chg
      evil
      evil-collection
    ];
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;
}
