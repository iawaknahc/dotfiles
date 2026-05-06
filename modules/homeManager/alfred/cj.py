import json
import sys

import cangjie

cj = cangjie.Cangjie(
    cangjie.versions.CANGJIE3,
    cangjie.filters.BIG5 | cangjie.filters.HKSCS | cangjie.filters.CHINESE,
)


def main():
    items = []
    query = "".join(sys.argv[1:])
    for ch in query:
        try:
            code = cj.get_codes_by_character(ch)[0].code
            radicals = "".join([cj.get_radical(c) for c in code])
            items.append(
                {
                    "title": ch,
                    "subtitle": f"{code} {radicals}",
                    "type": "default",
                    "arg": ch,
                    "mods": {
                        "cmd": {
                            "subtitle": code,
                            "arg": code,
                        },
                        "alt": {
                            "subtitle": radicals,
                            "arg": radicals,
                        },
                    },
                }
            )
        except cangjie.errors.CangjieNoCharsError:
            continue
    if len(items) > 0:
        print(json.dumps({"items": items}, ensure_ascii=False))
    else:
        print(
            json.dumps(
                {
                    "items": [
                        {
                            "title": "Type in some Chinese characters and get the Cangjie codes",
                            "type": "default",
                            "valid": False,
                        }
                    ]
                },
                ensure_ascii=False,
            )
        )


main()
