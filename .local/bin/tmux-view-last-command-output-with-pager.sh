#!/bin/sh

# This script works only when the shell writes OSC 133 A and OSC 133 C.
# As far as I know, Fish >= 4.0 is a shell doing that.
#
# tmux comes with a copy-mode command `{previous,next}-prompt [-o]` to move the cursor to the position of OSC 133 A and OSC 133 C.
# This script enters copy-mode and run these commands to gather the value of 2 variables, namely `copy_cursor_y` and `scroll_position`.
#
# tmux offers a single way to capture the scrollback of a pane, that is `capture-pane`.
# `capture-pane` takes `-S` and `-E` to limit the captured scrollback.
# With some calculation, we can derive a suitable `-S` and `-E` with `copy_cursor_y` and `scroll_position`.
#
# Now that we have captured the last command output captured by `capture-pane`,
# the remaining task is to view it with $PAGER.
#
# Since this script is supposed to be run with `run-shell`,
# it cannot invoke the pager directly.
# Instead, `new-window` is used to run the pager.
# Thanks to the default behavior of `new-window`, when the pager exits, the window is closed automatically.

tmux copy-mode

initial_copy_cursor_y="$(tmux display-message -p "#{copy_cursor_y}")"
initial_scroll_position="$(tmux display-message -p "#{scroll_position}")"

tmux send-keys -X previous-prompt -o

S_copy_cursor_y="$(tmux display-message -p "#{copy_cursor_y}")"
S_scroll_position="$(tmux display-message -p "#{scroll_position}")"

if [ "$initial_copy_cursor_y" = "$S_copy_cursor_y" ] && [ "$initial_scroll_position" = "$S_scroll_position" ]; then
	tmux send-keys -X cancel
	tmux display-message "Failed to find last command output. Maybe your shell does not support OSC 133, or your scrollback is just empty."
	exit 0
fi

tmux send-keys -X next-prompt

E_copy_cursor_y="$(tmux display-message -p "#{copy_cursor_y}")"
E_scroll_position="$(tmux display-message -p "#{scroll_position}")"

tmux send-keys -X cancel

S=$(( S_copy_cursor_y - S_scroll_position))

E=$(( E_copy_cursor_y - E_scroll_position))
E=$(( E - 1 )) # E is the line where the prompt starts, we certainly do not need it, so offset it by 1.

tmux capture-pane -p -e -N -S "$S" -E "$E" > /tmp/tmux_capture_pane.txt

if [ -z "$PAGER" ]; then
	PAGER=less
fi
tmux new-window "$PAGER /tmp/tmux_capture_pane.txt"
