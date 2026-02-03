{ pkgs, ... }:
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
  # Note that this is written in sh.
  # Fish shell sources hm-session-vars.sh with babelfish.
  home.sessionVariablesExtra = ''
    term="unknown-terminal"

    if [ -n "$TERM_PROGRAM" ]; then
      term="$TERM_PROGRAM@$TERM_PROGRAM_VERSION"
    elif [ -n "$TERM" ]; then
      term="$TERM"
    fi

    if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
      if [ -d "/Applications/iTerm.app/Contents/Resources/terminfo" ]; then
        export TERMINFO="/Applications/iTerm.app/Contents/Resources/terminfo"
      fi
    fi

    if [ -n "$TERMINFO" ]; then
      export TERMINFO_DIRS="$TERMINFO:$TERMINFO_DIRS"
      unset TERMINFO
    fi

    unset term
  '';

  # As of 2026-02-03, both nurses and ghostty include the terminfo for ghostty, clushing with each other.
  # home.packages = with pkgs; [
  #   ncurses
  # ];
}
