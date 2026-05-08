from __future__ import annotations

import json
import sys
from typing import Literal, TypedDict, cast

import cangjie  # pyright: ignore[reportMissingTypeStubs]

cj = cangjie.Cangjie(  # pyright: ignore[reportUnknownMemberType, reportAttributeAccessIssue, reportUnknownVariableType] # ty: ignore[unresolved-attribute] # pyrefly: ignore[missing-attribute]
    cangjie.versions.CANGJIE3,  # pyright: ignore[reportUnknownMemberType]
    cangjie.filters.BIG5 | cangjie.filters.HKSCS | cangjie.filters.CHINESE,  # pyright: ignore[reportUnknownMemberType]
)


class Item(TypedDict):
    title: str
    subtitle: str
    type: Literal["default"]
    arg: str
    mods: dict[Literal["cmd", "alt"], Mod]


class Mod(TypedDict):
    subtitle: str
    arg: str


def main():
    items = cast(list[Item], [])
    query = "".join(sys.argv[1:])
    for ch in query:
        try:
            code = cast(str, cj.get_codes_by_character(ch)[0].code)  # pyright: ignore[reportUnknownMemberType]
            radicals = "".join([cj.get_radical(c) for c in code])  # pyright: ignore[reportUnknownMemberType, reportUnknownArgumentType]
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
        except cangjie.errors.CangjieNoCharsError:  # pyright: ignore[reportAttributeAccessIssue, reportUnknownMemberType] # ty: ignore[unresolved-attribute] # pyrefly: ignore[missing-attribute]
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
