print $"sourcing ($nu.env-path)"

# NOTE: Variables or custom commands declared in the top-level in this file
# are still in scope of the shell.
# See https://github.com/nushell/nushell/issues/11818
# It is tempting to wrap them in a `do {||}` closure,
# but running in a closure changes the environment of the closure only.
# So we must run the effects in the top-level.
#
# The correct way to do this is to use export-env.

$env.config.show_banner = false
$env.config.edit_mode = "vi";
$env.PROMPT_INDICATOR_VI_NORMAL = {||
  let mode = $"(ansi red_bold)N(ansi reset)"
  let exit_code = $env.LAST_EXIT_CODE
  let prompt = if $exit_code == 0 {
    $"$"
  } else {
    $"(ansi red_bold)($exit_code) $(ansi reset)"
  }
  $"($mode) ($prompt) "
}
$env.PROMPT_INDICATOR_VI_INSERT = {||
  let mode = $"(ansi green_bold)I(ansi reset)"
  let exit_code = $env.LAST_EXIT_CODE
  let prompt = if $exit_code == 0 {
    $"$"
  } else {
    $"(ansi red_bold)($exit_code) $(ansi reset)"
  }
  $"($mode) ($prompt) "
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

  # I do not use nu as my main shell for now.
  # So we do not need to source the following script.
  # The environment variables are inherited from the main shell.
  #source_bash /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  #source_bash $"($env.HOME)/.nix-profile/etc/profile.d/hm-session-vars.sh"
}
