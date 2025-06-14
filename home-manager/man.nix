{
  pkgs,
  ...
}:
{
  programs.man.enable = true;
  # The default is false, but Fish turns this on.
  # That will make home-manager switch very slow on building the man-cache.
  # So we turn this off.
  programs.man.generateCaches = false;

  home.packages = with pkgs; [
    # The Linux man pages.
    # The entries may be irrelevant to macOS.
    man-pages

    # The POSIX man pages, in particular,
    # the package offers these sections:
    # - 0p: header files (like stdio.h)
    # - 1p: utilities (like sh, awk)
    # - 3p: library functions (like strftime)
    #
    # If you want to access the man page of POSIX sh, you run
    #   man 1p sh
    #
    # In contrast, running
    #   man sh
    # will likely take you to /usr/share/man/man1/sh.1 on macOS.
    #
    # To list all available variants, run
    #   man -aw sh
    # On my system, it prints
    #   /usr/share/man/man1/sh.1
    #   /Users/louischan/.nix-profile/share/man/man1p/sh.1p.gz
    man-pages-posix
  ];
}
