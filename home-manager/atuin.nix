{ ... }:
{
  programs.atuin.enable = true;
  programs.atuin.daemon.enable = false;

  programs.atuin.flags = [
    # When I press up, I really just want to run the previous command.
    # https://docs.atuin.sh/configuration/key-binding/#disable-up-arrow
    "--disable-up-arrow"
  ];

  programs.atuin.enableBashIntegration = true;
  programs.bash.bashrcExtra = ''
    unset HISTFILE
  '';

  programs.atuin.enableZshIntegration = true;
  programs.zsh.initContent = ''
    unset HISTFILE
  '';

  programs.atuin.enableFishIntegration = true;
  # https://fishshell.com/docs/current/interactive.html#searchable-command-history
  # https://fishshell.com/docs/current/interactive.html#private-mode
  # Atuin respects fish_private_mode, when fish_private_mode is on, Atuin does not save history.
  # Other than fish_private_mode, fish shell does not record a command if it is prefixed with a space,
  # similar to HISTCONTROL=ignorespace.

  # When Nushell has two kinds of history.
  # 1. The one we access with CTRL-R. This one can be disabled by starting Nushell with `--no-history`.
  # 2. Hitting the up arrow key. This one cannot be disabled. See https://github.com/nushell/nushell/issues/15258
  #
  # Since 0.112.1, $env.config.history.path was introduced.
  # It can be set to `null` to disable saving history to a file.
  # Atuin is NOT affected, and it can still record history.
  # https://www.nushell.sh/blog/2026-04-11-nushell_v0_112_1.html#history-file-path-can-now-be-configured
  programs.atuin.enableNushellIntegration = true;
  programs.nushell.extraConfig = ''
    $env.config.history.path = null
  '';

  programs.atuin.settings = {
    auto_sync = false;
    update_check = false;
    sync_address = "https://0.0.0.0:0";
    enter_accept = false;
    invert = true;
    # Disable the live-updating timestamp for very new history entries.
    prefers_reduced_motion = true;
    dotfiles = {
      enabled = false;
    };
    history_filter = [
      # Ignore any command that starts with 1 or more spaces.
      # Basically it is HISTCONTROL=ignorespace
      "^ +"
    ];
  };
}
