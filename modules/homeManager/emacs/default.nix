{ config, pkgs, ... }:
{
  programs.emacs.enable = true;
  programs.emacs.package =
    # It has to be Emacs Macport otherwise the scrollbar has a non-customizable white background color.
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs-macport else pkgs.emacs-pgtk;
  programs.emacs.extraPackages =
    emacsPackages: with emacsPackages; [
      catppuccin-theme
      mu4e
    ];
  programs.emacs.extraConfig = ''
    (setq mu4e-attachment-dir "${config.home.homeDirectory}/Downloads")
  '';
  home.file.".emacs.d/init.el".source = ./emacs.d/init.el;
}
