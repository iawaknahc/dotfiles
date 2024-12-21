print $"sourcing ($nu.env-path)"

# nushell < 0.101 does not increment SHLVL.
# See https://github.com/nushell/nushell/issues/14384
let v = version
if $v.major == 0 and $v.minor < 101 {
  $env.SHLVL = $env | get --sensitive --ignore-errors SHLVL | default 0 | into int | $in + 1
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

def --env source_bash [p] {
  bash -c $"source '($p)' && env" |
    lines |
    parse --regex '^(?P<name>[A-Z][a-zA-Z0-9_]*)=(?<value>.*)$' |
    where { |x| ($x.name not-in $env) or ($env | get $x.name) != $x.value } |
    where name not-in ['_', 'SHLVL', 'LAST_EXIT_CODE', 'DIRS_POSITION'] |
    transpose --header-row |
    into record |
    load-env
}

source_bash /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
source_bash $"($env.HOME)/.nix-profile/etc/profile.d/hm-session-vars.sh"
