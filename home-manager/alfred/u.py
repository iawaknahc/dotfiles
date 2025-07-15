import json
import os
import sqlite3
import sys
from contextlib import closing
from dataclasses import dataclass
from functools import cached_property
from typing import Self


def codepoint_to_notation(codepoint: int) -> str:
    return f"{codepoint:04X}"


def preprocess_query(argv: list[str]) -> str:
    query = " ".join(argv).upper()
    parts = [part.strip() for part in query.split(" ")]
    parts = [part for part in parts if part != ""]
    normalized = []
    for part in parts:
        # We do not want `latin letter a` to be rewritten into `latin letter 000A`.
        # Thus we only rewrite when the part is at least 2 characters.
        if len(part) >= 2:
            try:
                codepoint = int(part, base=16)
                notation = codepoint_to_notation(codepoint)
                normalized.append(notation)
            except ValueError:
                normalized.append(part)
        else:
            normalized.append(part)
    return " ".join(normalized)


def use_trigram(query: str) -> bool:
    parts = query.split(" ")
    for part in parts:
        if len(part) < 3:
            return False
    return True


def codepoints_to_cps(codepoints: list[int]) -> str:
    return " ".join([codepoint_to_notation(cp) for cp in codepoints])


def cps_to_codepoints(cps: str) -> list[int]:
    return [int(cp, base=16) for cp in cps.strip().split(" ")]


@dataclass
class CodepointSequence:
    codepoints: list[int]
    name: str
    tts: str | None

    @cached_property
    def cps(self) -> str:
        return codepoints_to_cps(self.codepoints)

    @classmethod
    def from_sqlite3(cls, t: tuple[str, str, str | None]) -> Self:
        cps = t[0]
        name = t[1]
        tts = t[2]
        codepoints = cps_to_codepoints(cps)
        return cls(codepoints=codepoints, name=name, tts=tts)

    def __hash__(self):
        return hash((self.cps,))

    def __eq__(self, other):
        return self.cps == other.cps

    def to_item(self):
        notations = "".join([codepoint_to_notation(cp) for cp in self.codepoints])

        # No idea how to encode surrogate with json.
        # It seems that there is no way pass "surrogatepass".
        s = ""
        for cp in self.codepoints:
            if cp >= 0xD800 and cp <= 0xDFFF:
                s = notations
                break
            s += chr(cp)

        desc = self.name
        if self.tts is not None and self.tts != desc:
            desc = f"{desc} {self.tts}"

        return {
            "title": s,
            "subtitle": desc,
            "type": "default",
            "arg": s,
            "mods": {
                "cmd": {
                    "subtitle": notations,
                    "arg": notations,
                },
            },
        }


def error():
    print(
        json.dumps(
            {
                "items": [
                    {
                        "title": "No match. Refine your search.",
                        "type": "default",
                        "valid": False,
                    }
                ],
            },
            ensure_ascii=False,
        )
    )


def get_matches(conn: sqlite3.Connection, query: str) -> list[CodepointSequence]:
    # We assume the iteration order of dict is insertion order.
    matches = {}

    exact_match = conn.execute(
        """
        SELECT cps, name, tts FROM codepoint_sequence
        WHERE cps = ?
        """,
        (query,),
    ).fetchone()
    if exact_match is not None:
        cs = CodepointSequence.from_sqlite3(exact_match)
        matches[cs] = cs

    trigram = use_trigram(query)
    rows = []
    if trigram:
        rows = conn.execute(
            """
            SELECT cps, name, tts FROM codepoint_sequence_trigram
            WHERE codepoint_sequence_trigram MATCH ?
            ORDER BY rank
            LIMIT 10
            """,
            (query,),
        ).fetchall()
    else:
        rows = conn.execute(
            """
            SELECT cps, name, tts FROM codepoint_sequence_porter
            WHERE codepoint_sequence_porter MATCH ?
            ORDER BY rank
            LIMIT 10
            """,
            (query,),
        ).fetchall()

    for row in rows:
        cs = CodepointSequence.from_sqlite3(row)
        if cs not in matches:
            matches[cs] = cs

    ordered_matches = [m for m in matches.keys()]

    # Return at most 9 matches so that the result list in Alfred does not have a scrollbar.
    return ordered_matches[:9]


def main():
    query = ""
    query = preprocess_query(sys.argv[1:])

    if query == "":
        error()
        return

    sqlite3_database_file = os.path.expanduser(
        "~/.nix-profile/share/unicode/unicode.sqlite3"
    )

    with closing(sqlite3.connect(sqlite3_database_file, autocommit=False)) as conn:
        matches = get_matches(conn, query)
        if len(matches) == 0:
            error()
            return

        items = [m.to_item() for m in matches]
        print(json.dumps({"items": items}, ensure_ascii=False))


main()
