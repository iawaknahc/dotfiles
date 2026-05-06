{ ... }:
{
  programs.x-elvish.enable = true;
  programs.x-elvish.rcExtra = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v elvish` is an empty string.
    set-env SHELL (command -v elvish)

    # We cannot bind Ctrl-J because Elvish does not support Kitty keyboard protocol
    # https://github.com/elves/elvish/issues/1244
    set edit:listing:binding[Ctrl-N] = { edit:listing:down }
    set edit:listing:binding[Ctrl-P] = { edit:listing:up }
  '';
}
