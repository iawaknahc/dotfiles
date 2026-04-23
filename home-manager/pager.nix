{ ... }:
{
  programs.less.enable = true;
  home.sessionVariables = {
    # Git set `LESS=FRX` if LESS is unset.
    # So we set it here.
    # In particular, we removed the flag `-F`, which causes `less` to exit if the file fits in one screen.
    # See https://github.com/git/git/blob/v2.54.0/Makefile#L2418
    LESS = "RX";

    # PAGER is set by nix-darwin by default.
    # Undo its effect by setting it here again.
    # See https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-25.11/modules/environment/default.nix#L160
    PAGER = "less";
  };
}
