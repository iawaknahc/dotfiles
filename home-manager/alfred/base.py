import json
import sys
from typing import List


def string_to_int(number_str):
    number_str = number_str.strip()

    # Strip sign
    if number_str.startswith("-"):
        number_str = number_str[1:]
    elif number_str.startswith("+"):
        number_str = number_str[1:]

    digits = None
    if number_str.lower().startswith("0x"):
        base = 16
        digits = number_str[2:]
    elif number_str.lower().startswith("0o"):
        base = 8
        digits = number_str[2:]
    elif number_str.lower().startswith("0b"):
        base = 2
        digits = number_str[2:]
    else:
        base = 10
        digits = number_str

    if digits is None:
        raise ValueError("No digits found after prefix")

    return int(digits, base)


def error():
    print(
        json.dumps(
            {
                "items": [
                    {
                        "title": "Enter a number in decimal, hexadecimal (0x), octal (0o), binary (0b)",
                        "type": "default",
                        "valid": False,
                    }
                ],
            },
            ensure_ascii=False,
        )
    )


def format_to_different_bases(i: int) -> List[str]:
    return [
        f"{i:d}",
        f"0x{i:x}",
        f"0o{i:o}",
        f"0b{i:b}",
    ]


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1]

    if arg == "":
        error()
        return

    try:
        items = [
            {
                "title": i,
                "type": "default",
                "arg": i,
            }
            for i in format_to_different_bases(string_to_int(arg))
        ]
        print(json.dumps({"items": items}, ensure_ascii=False))
    except ValueError:
        error()
        return


main()
