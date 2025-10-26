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

# WARNING: nix-darwin setEnvironment.sh is not sourced.
# WARNING: home.sessionVariables are not respected.
# So nu cannot be used as a main shell.
