#!/usr/bin/env nu

# This script opens the applications and move them to desired Aerospace workspaces.
# Intended to be used when the machine restarts.

def open_app [app_name] { osascript -e $"tell application \"($app_name)\" to activate" }

def get_window_id [app_name] {
    let window = aerospace list-windows --all --json | from json | where app-name == $app_name | first
    if $window == null {
        return null
    }
    $window | get window-id
}

def move_app_to_workspace [app_name, workspace_id] {
    let window_id = get_window_id $app_name
    if $window_id != null {
        # Suppress the stderr message that the window is already in that workspace.
        aerospace move-node-to-workspace --window-id $window_id $workspace_id e> /dev/null
    }
}

[Firefox, Ghostty, Mail, Obsidian, Claude] | enumerate | each {|e|
	let app_name = $e.item
	let workspace = $e.index + 1 | into string
	open_app $app_name
	move_app_to_workspace $app_name $workspace
}
sketchybar --reload
