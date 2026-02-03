{ pkgs, ... }:
{
  # Wrap ls.
  # This idea is borrowed from fish shell.
  # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/ls.fish
  # Unlike fish shell, we explicitly use the ls from coreutils.
  ls =
    with pkgs;
    (writeShellScript "ls" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${coreutils-prefixed}/bin/gls -F --color "$@"
      else
        ${coreutils-prefixed}/bin/gls "$@"
      fi
    '');

  # Wrap grep.
  # This idea is borrowed from fish shell.
  # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/grep.fish
  # Unlike fish shell, we explicitly use the grep from gnugrep.
  #
  # Caveat
  # The gnugrep package offers egrep and fgrep as well.
  # Since we no longer install the original gnugrep package, they are not installed.
  grep =
    with pkgs;
    (writeShellScript "grep" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${gnugrep}/bin/grep --color "$@"
      else
        ${gnugrep}/bin/grep "$@"
      fi
    '');

  # Wrap diff.
  # This idea is borrowed from fish shell.
  # See https://github.com/fish-shell/fish-shell/blob/4.0.0/share/functions/diff.fish
  # Unlike fish shell, we explicitly use the diff from diffutils.
  #
  # Caveat
  # The diffutils package offers diff3 and cmp as well.
  # Since we no longer install the original diffutils package, they are not installed.
  diff =
    with pkgs;
    (writeShellScript "diff" ''
      # Is connected to the terminal
      if test -t 0 && test -t 1 && test -t 2; then
        ${diffutils}/bin/diff --color "$@"
      else
        ${diffutils}/bin/diff "$@"
      fi
    '');
}
