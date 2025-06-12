#!/Users/louischan/.nix-profile/bin/python3

# https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
# https://www.alfredapp.com/help/workflows/script-environment-variables/

import argparse
import sys
import json
import shlex
import uuid


def error(item):
    print(json.dumps({
        "items": [item],
    }, ensure_ascii=False))


def success(items):
    print(json.dumps({
        "items": items,
    }, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser(
        description="Just Alfred script filter",
    )
    subparsers = parser.add_subparsers(dest="subcommand")

    subcommand_uuid = subparsers.add_parser("uuid")
    subcommand_uuid.add_argument("ignore", nargs="*")

    try:
        shlex_args = shlex.split(sys.argv[1])
        print(shlex_args, file=sys.stderr)
        args = parser.parse_args(shlex_args)
    except:
        error({
            "valid": False,
            "title": "Invalid",
            "subtitle": "Invalid",
        })
        return

    if args.subcommand == "uuid":
        lowercase_uuid4 = str(uuid.uuid4()).lower()
        uppercase_uuid4 = lowercase_uuid4.upper()
        success([
            {
                "title": "UUID4 in lowercase, hold ⌘ for uppercase",
                "type": "default",
                "subtitle": lowercase_uuid4,
                "arg": lowercase_uuid4,
                "mods": {
                    "cmd": {
                        "subtitle": uppercase_uuid4,
                        "arg": uppercase_uuid4,
                    }
                }
            }
        ])
        return

if __name__ == "__main__":
    main()
