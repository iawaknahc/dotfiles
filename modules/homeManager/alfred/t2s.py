from __future__ import annotations

import json
import sys
from typing import cast

import opencc
import pyperclip


def main():
    text = ""
    if len(sys.argv) > 1:
        text = " ".join(sys.argv[1:])

    if text == "":
        clipboard = pyperclip.paste()
        if clipboard is None:  # pyright: ignore [reportUnnecessaryComparison]
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
        converter = opencc.OpenCC("t2s.json")
        converted = cast(str, converter.convert(text))
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
