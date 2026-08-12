{ config, ... }:
{
  # GNU Info
  # The module sets home.extraOutputsToInstall so it is better to use it,
  # than to installing the package directly.
  programs.info.enable = true;
  programs.emacs.extraConfig = ''
    ;; Added in modules/homeManager/gnuinfo/default.nix
    ;; It is to make all Info manuals installed in the Nix profile available in Emacs.
    (with-eval-after-load 'info
      (add-to-list 'Info-directory-list "${config.home.profileDirectory}/share/info"))
  '';
}
