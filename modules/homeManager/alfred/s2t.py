import json
import sys

import opencc
import pyperclip


def main():
    text = ""
    if len(sys.argv) > 1:
        text = " ".join(sys.argv[1:])

    if text == "":
        clipboard = pyperclip.paste()
        if clipboard is None:
            clipboard = ""
        text = clipboard

    if text == "":
        print(
            json.dumps(
                {
                    "items": [
                        {
                            "title": "It reads from clipboard or argument",
                            "type": "default",
                            "valid": False,
                        }
                    ],
                }
            )
        )
    else:
        converter = opencc.OpenCC("s2t.json")
        converted = converter.convert(text)
        print(
            json.dumps(
                {
                    "items": [
                        {
                            "title": converted,
                            "type": "default",
                            "subtitle": text,
                            "arg": converted,
                        }
                    ],
                }
            )
        )


main()
