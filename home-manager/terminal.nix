{ ... }:
{
  # Nix install all terminfo (not limited to ncurses, but also any package that come with a terminfo, like alacritty) to ~/.nix-profile/share/terminfo
  # But this is not a standard location.
  # ~/.terminfo is a standard location that will be read by ncurses and unibilium, and
  # it is inside home directory, which can be managed by home-manager.
  #
  # nix-darwin sets TERMINFO_DIRS to include ~/.nix-profile/share/terminfo by default.
  # So we have nothing to do.

  # TERMINFO and TERMINFO_DIRS
  #
  # We have 2 problems to deal with.
  # 1. Some terminal emulators, like iTerm2, does not set TERMINFO at all. But it does include its terminfo in its application directory.
  # 2. Some terminal emulators, like kitty and ghostty, set TERMINFO to their application directory containing only their terminfo.
  #    This will cause tic(1) writing to TERMINFO. See https://github.com/ghostty-org/ghostty/discussions/4557#discussioncomment-11733059
  #
  # For problem 1, we help those terminal emulators to set TERMINFO. Then problem 1 becomes problem 2.
  # For problem 2, we unset TERMINFO, and set TERMINFO_DIRS correctly.
  #
  # Since we no longer use iTerm2, we can ignore problem 1.
  # Given that we almost never use tic(1), we can ignore problem 2.
  # Ignoring both problems allow us to avoid using home.sessionVariablesExtra which is not supported by Nushell.

  # As of 2026-02-03, both ncurses and ghostty install ~/.nix-profile/share/terminfo/67/ghostty, clashing with each other.
  #home.packages = with pkgs; [
  #  ncurses
  #];
}
