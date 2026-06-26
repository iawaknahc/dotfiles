{ pkgs, ... }:
{
  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs-pgtk;
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      catppuccin-theme
    ];
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;
}
