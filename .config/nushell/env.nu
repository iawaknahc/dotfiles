# NOTE: Variables or custom commands declared in the top-level in this file
# are still in scope of the shell.
# See https://github.com/nushell/nushell/issues/11818
# It is tempting to wrap them in a `do {||}` closure,
# but running in a closure changes the environment of the closure only.
# So we must run the effects in the top-level.
#
# The correct way to do this is to use export-env.

$env.config.show_banner = false
# In preparation for using neovim as default terminal program,
# we disable vi mode in shell.
# $env.config.edit_mode = "vi";
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

# WARNING: nix-darwin setEnvironment.sh is not sourced.
# WARNING: home.sessionVariables are not respected.
# So nu cannot be used as a main shell.
