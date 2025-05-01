#!/usr/bin/osascript

on run argv
  set prev to the clipboard
  set the clipboard to item 1 of argv

  tell application "System Events"
    keystroke "v" using command down
    -- Add some delay to let the application to handle the keystroke.
    -- If we restore the clipboard too fast, the pasted content is the original content.
    delay 0.1
  end tell

  set the clipboard to prev
end run
