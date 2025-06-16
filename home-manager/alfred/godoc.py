import json
import os
import subprocess
import sys
from urllib.parse import urlsplit, urljoin, quote

import pyperclip

def to_item(url_str: str, subtitle: str):
    if url_str == "":
        return None

    if not (url_str.startswith("http://") or url_str.startswith("https://")):
        url_str = "https://" + url_str

    parsed = urlsplit(url_str)

    # Special case: If the URL is already a URL to the doc, skip it.
    if parsed.netloc == "pkg.go.dev":
        return None

    a = urljoin("https://pkg.go.dev", quote(parsed.netloc)) + "/"
    a = urljoin(a, "." + quote(parsed.path))

    return {
        "title": f"Open {a}",
        "type": "default",
        "subtitle": subtitle,
        "arg": a,
    }


def main():
    items = []

    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()

    # When argument is provided, we skip reading the clipboard, or
    # inspecting the browsers.
    # Inspecting the browsers may block sometimes.
    if arg != "":
        arg_item = to_item(arg, "From argument")
        if arg_item is not None:
            items.append(arg_item)
    else:
        clipboard = pyperclip.paste()
        if clipboard is None:
            clipboard = ""
        else:
            clipboard = clipboard.strip()

        clipboard_item = to_item(clipboard, "From clipboard")
        if clipboard_item is not None:
            items.append(clipboard_item)

        try:
            process = subprocess.run([
                os.environ["HS"],
                os.environ["HS_SCRIPT"],
            ], capture_output=True, text=True, check=True)
            browsers_output = json.loads(process.stdout)
        except:
            browsers_output = { "browsers": [] }

        for b in browsers_output["browsers"]:
            name = b["name"]
            url = b.get("url")
            if url is None or url == "":
                continue
            item = to_item(url, f"From {name}")
            if item is not None:
                items.append(item)

    if len(items) == 0:
        print(json.dumps({
            "items": [
                {
                    "title": "No URL provided in argument or in clipboard",
                    "type": "default",
                    "valid": False,
                }
            ]
        }, ensure_ascii=False))
        return

    print(json.dumps({ "items": items }, ensure_ascii=False))


main()
