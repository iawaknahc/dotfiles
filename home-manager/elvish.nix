{ ... }:
{
  programs.x-elvish.enable = true;
  programs.x-elvish.rcExtra = ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v elvish` is an empty string.
    set-env SHELL (command -v elvish)
  '';
}
