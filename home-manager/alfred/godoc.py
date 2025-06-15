import json
import sys
from urllib.parse import urlsplit, urljoin, quote

import pyperclip

def to_item(url_str: str, subtitle: str):
    if url_str == "":
        return None

    if not (url_str.startswith("http://") or url_str.startswith("https://")):
        url_str = "https://" + url_str

    parsed = urlsplit(url_str)
    a = urljoin("https://pkg.go.dev", quote(parsed.netloc)) + "/"
    a = urljoin(a, "." + quote(parsed.path))

    return {
        "title": f"Open {a}",
        "type": "default",
        "subtitle": subtitle,
        "arg": a,
    }


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()

    clipboard = pyperclip.paste()
    if clipboard is None:
        clipboard = ""
    else:
        clipboard = clipboard.strip()

    items = []

    arg_item = to_item(arg, "From argument")
    if arg_item is not None:
        items.append(arg_item)

    clipboard_item = to_item(clipboard, "From clipboard")
    if clipboard_item is not None:
        items.append(clipboard_item)

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
