{ ... }:
{
  programs.x-elvish.enable = true;
  programs.x-elvish.rcExtra = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v elvish` is an empty string.
    set-env SHELL (command -v elvish)

    var term unknown-terminal
    if (not-eq $E:TERM_PROGRAM "") {
      set term = $E:TERM_PROGRAM'@'$E:TERM_PROGRAM_VERSION
    } elif (not-eq $E:TERM "") {
      set term = $E:TERM
    }
    if (not-eq $E:TERM "") {
      printf "%s sets $TERM to %s\n" $term $E:TERM
    }
    if (not-eq $E:TERMINFO "") {
      printf "%s sets $TERMINFO to %s\n" $term $E:TERMINFO
      printf "unset TERMINFO and set TERMINFO_DIRS instead\n"

      set-env TERMINFO_DIRS $E:TERMINFO':'$E:TERMINFO_DIRS
      unset-env TERMINFO
    }
  '';
}
