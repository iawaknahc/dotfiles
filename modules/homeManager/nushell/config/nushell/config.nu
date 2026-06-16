# The current best practice is just write config.nu
# See https://www.nushell.sh/book/configuration.html#configuration-overview

# NOTE: Variables or custom commands declared in the top-level in this file
# are still in scope of the shell.
# See https://github.com/nushell/nushell/issues/11818
# It is tempting to wrap them in a `do {||}` closure,
# but running in a closure changes the environment of the closure only.
# So we must run the effects in the top-level.
#
# The correct way to do this is to use export-env.

# WARNING: nix-darwin setEnvironment.sh is not sourced.
# WARNING: home.sessionVariables are not respected.
# So nu cannot be used as a main shell.

# In preparation for using neovim as default terminal program,
# we disable vi mode in shell.
# $env.config.edit_mode = "vi";

# As of 2026-06-16, Nushell (Reedline) does not support binding key sequences.
# So we cannot bind ctrl-x ctrl-e to edit the command line.
# We have to use the default ctrl-o key binding.

# https://www.nushell.sh/book/background_jobs.html#job-suspension
alias fg = job unfreeze

# https://www.nushell.sh/book/configuration.html#remove-welcome-message
$env.config.show_banner = false

# Ensure SHELL is correctly set
$env.SHELL = (command -v nu)

# Customize the UI and UX of the completion menu.
# See https://www.nushell.sh/book/line_editor.html#completion-menu
$env.config.menus ++= [
    {
        name: completion_menu
        only_buffer_difference: false # No idea what this is. The value is taken from the documentation.
        marker: "" # Disable the marker so that the command line does not flicker.
        # `layout: columnar` is the default layout.
        # Make it 1-column for easier reading from top to bottom. I always find it hard to understand the reading order when columns > 1.
        type: {layout: columnar, columns: 1}
        style: {} # Omitting this field is a type error.
    }
]

# Take a Nushell table, pipe it into DuckDB, run the specified query, return a Nushell table.
def nu-duckdb [
    query: string # The DuckDB query to run
]: table -> table {
    let full_query = $"
      CREATE TABLE data AS SELECT * FROM read_json\('/dev/stdin'\);
      COPY \(($query)\) TO '/dev/stdout' \(format JSON, ARRAY true\)"
    $in | to json | duckdb -c $full_query | from json
}
