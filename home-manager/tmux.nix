{ ... }:
{
  programs.tmux.enable = true;

  # set-option -g prefix C-Space
  # unbind-key C-b
  # bind-key C-Space send-prefix
  #
  # Note that bind-key C-Space is not repeatable.
  programs.tmux.prefix = "C-Space";

  # set-option -g status-keys vi
  # set-option -g mode-keys vi
  programs.tmux.keyMode = "vi";

  # set-option -g base-index 1
  # set-window-option -g pane-base-index 1
  #
  # Count windows and panes from 1, instead of 0.
  # Sessions are still counted from 0 though.
  # See https://github.com/tmux/tmux/issues/769
  programs.tmux.baseIndex = 1;

  # bind-key k select-pane -U
  # bind-key j select-pane -D
  # bind-key h select-pane -L
  # bind-key l select-pane -R
  # bind-key -r K resize-pane -U 1
  # bind-key -r J resize-pane -D 1
  # bind-key -r H resize-pane -L 1
  # bind-key -r L resize-pane -R 1
  programs.tmux.customPaneNavigationAndResize = true;
  programs.tmux.resizeAmount = 1;

  # https://superuser.com/a/1809494
  programs.tmux.escapeTime = 50;

  programs.tmux.focusEvents = true;
  programs.tmux.historyLimit = 100000;

  # set-option -g mouse on
  #
  # Make tmux behave like Terminal.app
  programs.tmux.mouse = true;

  # Here is what I want
  # 1. I am currently in a fish login shell.
  # 2. Since I am already in a fish shell, config.fish has been sourced and the environment is assumed to be set up correctly.
  # 3. I want to start tmux.
  # 4. Thus I start tmux without any options nor arguments.
  # 5. When tmux is invoked in this way, it has the following behavior.
  #
  # a. tmux uses the value of default-shell (which must be an absolute path) to invoke default-command.
  # b. When default-shell is unspecified, the value is taken from $SHELL.
  # c. When default-command is unspecified, tmux replaces itself with a shell by invoking default-shell with -l, resulting a login shell. See https://github.com/tmux/tmux/blob/e75f3a0060971bd9bcd3ff90ef4a6614b05b0963/spawn.c#L360
  # d. If default-command is specified, tmux forks itself, and invoke default-command with default-shell -c.
  # e. Thus, when default-command is specified, you will have two shells.
  # f. Having two shells is undesirable, for example, $SHLVL is 1 more.
  # g. It follows that default-command SHOULD be `exec some-shell`, so that there is only 1 shell, not 2.
  #
  # A. A login sh shell (which is just a bash) sources /etc/profile, as documented in the INVOCATION section of `man bash`.
  # B. /etc/profile on macOS invokes /usr/libexec/path_helper
  # C. /usr/libexec/path_helper set PATH to empty, and rebuild it.
  # D. Thus running a login shell more than once is harmful.
  #
  # Of course, this is a problem when $SHELL is bash.
  # When $SHELL is fish, it is not a problem at all, because fish does not source /etc/profile.
  #
  # We set default-shell to /bin/sh so that default-command is run with /bin/sh.
  # This is a more predictable behavior, as this is what system(3) does.
  #
  # default-command is `exec ${SHELL}` so this short-lived $SHELL instance is replaced with $SHELL.
  # Since $SHELL is invoked without -l, the shell is not a login shell.
  programs.tmux.shell = "/bin/sh";

  # $TERMINFO and $TERMINFO_DIRS
  #
  # Some terminal emulators, like kitty and ghostty, set $TERMINFO to point to a directory
  # containing the most accurate terminfo describing their capabilities.
  # This is good because the users do not need to provision the terminfo themselves.
  # However, setting TERMINFO has the effect of only looking at that directory.
  # If $TERMINFO is left set inside tmux, the terminal-based program cannot see the capability of tmux, since that directory does not contain the terminfo of tmux-256color.
  #
  # Thus setting $TERMINFO is actually a problem.
  # A more correct approach is to set $TERMINFO_DIRS instead.
  # Those terminal emulators set $TERMINFO before launching the shell,
  # we can set $TERMINFO_DIRS and unset $TERMINFO in shell initialization script.
  # See home.nix for details.
  #
  #
  # $TERM
  #
  # A correct value of $TERM tells terminal-based programs how to interact with the terminal.
  # Terminal-based programs, in particular, neovim, have a very strict requirement on the value being correct.
  # See :help terminfo for details.
  #
  # The value must match the terminal.
  # For example, if it is a kitty terminal, then the value MUST BE xterm-kitty.
  # Some terminal emulators, such as kitty and ghostty, get this right by default.
  #
  # tmux, being a terminal multiplexer, is also a terminal.
  # tmux sets $TERM to the value of the option default-terminal.
  # The default value of default-terminal is screen.
  # To let terminal-based programs to utilizes all capabilities of tmux,
  # we use the preferred value, tmux-256color.
  #
  #
  # Conclusion
  #
  # To make things work, we need
  # 1. Terminal emulators, or terminal multiplexers set $TERM correctly.
  #   1.1. kitty sets $TERM to xterm-kitty (done by kitty by default)
  #   1.2. ghostty sets $TERM to xterm-ghostty (done by ghostty by default)
  #   1.3. iTerm2 sets $TERM to xterm-256color. (You can ask iTerm2 to do this)
  #   1.4. alacritty sets $TERM to alacritty. (No idea why it does not do this by default)
  # 2. $TERMINFO is unset, and $TERMINFO_DIRS contains a list of directory that
  #    include all terminal emulators and terminal multiplexers. For terminal emulators
  #    that set $TERMINFO, $TERMINFO is PREPENDED to $TERMINFO_DIRS, so the bundled, most
  #    accurate capabilities advertised by the terminal emulators are used.
  #   2.1. kitty bundles its terminfo. The entries are xterm-kitty.
  #   2.2. ghostty bundles its terminfo. The entries are xterm-ghostty.
  #   2.3. alacritty bundles its terminfo. The entries are alacritty and alacritty-direct.
  #   2.4. iTerm2 bundles its terminfo. The entries are xterm, xterm-new, xterm-256color.
  #        So now we see why iTerm2 set $TERM to xterm-256color. It is because
  #        it works by providing a modified terminfo of xterm-256color.
  programs.tmux.terminal = "tmux-256color";

  programs.tmux.extraConfig = builtins.readFile ../.config/tmux/tmux.conf;
}
