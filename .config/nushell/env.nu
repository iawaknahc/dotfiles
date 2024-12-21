print $"sourcing ($nu.env-path)"

# NOTE: Variables or custom commands declared in the top-level in this file
# are still in scope of the shell.
# See https://github.com/nushell/nushell/issues/11818
# It is tempting to wrap them in a `do {||}` closure,
# but running in a closure changes the environment of the closure only.
# So we must run the effects in the top-level.
#
# The correct way to do this is to use export-env.

# nushell < 0.101 does not increment SHLVL.
# See https://github.com/nushell/nushell/issues/14384
export-env {
  let v = version
  if $v.major == 0 and $v.minor < 101 {
    $env.SHLVL = $env | get --sensitive --ignore-errors SHLVL | default 0 | into int | $in + 1
  }
}

$env.config.show_banner = false
$env.config.edit_mode = "vi";
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = {||
  $"(ansi red_bold)[N](ansi reset) $ "
}
$env.PROMPT_INDICATOR_VI_INSERT = {||
  $"(ansi green_bold)[I](ansi reset) $ "
}

$env.PROMPT_COMMAND = {||
  $"(ansi yellow_bold)[($env.SHLVL)](ansi reset)"
}

export-env {
  def --env source_bash [p] {
    let t = bash -c $"source '($p)' && env" |
      lines |
      parse --regex '^(?P<name>[A-Z][a-zA-Z0-9_]*)=(?<value>.*)$' |
      where { |x| ($x.name not-in $env) or ($env | get $x.name) != $x.value } |
      where name not-in ['_', 'SHLVL', 'LAST_EXIT_CODE', 'DIRS_POSITION']

    let s = $t | update name {|row| '+' + $row.name} | get name | str join ' '
    if ($s | is-not-empty) {
      print $"($s)"
    }

    $t | transpose --header-row | into record | load-env
  }

  source_bash /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  source_bash $"($env.HOME)/.nix-profile/etc/profile.d/hm-session-vars.sh"
}
