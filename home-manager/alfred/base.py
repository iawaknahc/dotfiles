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


def format_to_different_bases(i: int) -> List[dict]:
    return [
        {
            "title": f"{i:d}",
            "subtitle": "Decimal (Base 10)",
            "type": "default",
            "arg": f"{i:d}",
        },
        {
            "title": f"0x{i:x}",
            "subtitle": "Hexadecimal (Base 16)",
            "type": "default",
            "arg": f"0x{i:x}",
        },
        {
            "title": f"0o{i:o}",
            "subtitle": "Octal (Base 8)",
            "type": "default",
            "arg": f"0o{i:o}",
        },
        {
            "title": f"0b{i:b}",
            "subtitle": "Binary (Base 2)",
            "type": "default",
            "arg": f"0b{i:b}",
        },
    ]


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1]

    if arg == "":
        error()
        return

    try:
        items = format_to_different_bases(string_to_int(arg))
        print(json.dumps({"items": items}, ensure_ascii=False))
    except ValueError:
        error()
        return


main()
