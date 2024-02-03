#!/usr/bin/env python3

from typing import Any, Optional
from subprocess import check_output, Popen, run, PIPE
import json
import os


def ls() -> Any:
    ls_output = check_output(["kitty", "@", "ls"])
    os_windows = json.loads(ls_output)
    return os_windows


def fzf(os_windows: Any) -> Optional[int]:
    KITTY_LISTEN_ON = os.environ["KITTY_LISTEN_ON"]
    args = [
        "/usr/local/bin/fzf",
        "--reverse",
        "--delimiter=:",
        "--preview",
        f"kitty @ --to {KITTY_LISTEN_ON} get-text --ansi --match id:{{2}}",
    ]
    p = Popen(args, stdin=PIPE, stdout=PIPE)
    lines = []
    for os_window in os_windows:
        if os_window["is_active"] and os_window["is_focused"]:
            tabs = os_window["tabs"]
            for tab_index, tab in enumerate(tabs):
                tab_title = tab["title"]
                # The tab that launch this script will have active_window_history of this overlay window only.
                # This is not very useful.
                # So we show the content of the first window as the preview of the tab.
                first_window_id = tab["windows"][0]["id"]
                # The window ID is solely for fzf to display preview.
                line = f"{tab_index+1}:{first_window_id}:{tab_title}\n"
                lines.append(line)
    fzf_input = "".join(lines)
    fzf_output_bytes, _ = p.communicate(input=fzf_input.encode())
    fzf_output = fzf_output_bytes.decode()
    splits = fzf_output.split(":")
    if len(splits) == 0:
        return None
    tab_index_plus_one = int(splits[0])
    tab_index = tab_index_plus_one - 1
    return tab_index


def focus_tab(tab_index: int) -> None:
    run(["kitty", "@", "focus-tab", "--match", f"index:{tab_index}"])


def main() -> str:
    os_windows = ls()
    tab_index = fzf(os_windows)
    if tab_index is not None:
        focus_tab(tab_index)
    return ""


if __name__ == "__main__":
    main()
