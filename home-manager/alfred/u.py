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


def preprocess_query(argv: list[str]) -> list[str]:
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
    return normalized


def prepare_plain_query(query: list[str]) -> str:
    return " ".join(query)


def prepare_fts5_query(query: list[str]) -> str:
    escaped = []
    for term in query:
        # Escape " by doubling it
        # See https://www.sqlite.org/fts5.html#fts5_strings
        term = term.replace('"', '""')
        # Enclose the entire query in " to make a FTS5 string.
        term = f'"{term}"'
        escaped.append(term)
    return " ".join(escaped)


def use_trigram(query: list[str]) -> bool:
    for term in query:
        if len(term) < 3:
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
        notations = " ".join([codepoint_to_notation(cp) for cp in self.codepoints])

        s = ""
        for cp in self.codepoints:
            if cp >= 0xD800 and cp <= 0xDFFF:
                # Alfred does not handle UTF-8 encoded surrogate very well.
                # So we do not feed that to Alfred.
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


def get_matches(conn: sqlite3.Connection, query: list[str]) -> list[CodepointSequence]:
    # We assume the iteration order of dict is insertion order.
    matches = {}

    query_plain = prepare_plain_query(query)

    exact_match = conn.execute(
        """
        SELECT cps, name, tts FROM codepoint_sequence
        WHERE cps = ?
        """,
        (query_plain,),
    ).fetchone()
    if exact_match is not None:
        cs = CodepointSequence.from_sqlite3(exact_match)
        matches[cs] = cs

    trigram = use_trigram(query)
    rows = []
    query_fts5 = prepare_fts5_query(query)
    if trigram:
        rows = conn.execute(
            """
            SELECT cps, name, tts FROM codepoint_sequence_trigram
            WHERE codepoint_sequence_trigram MATCH ?
            ORDER BY rank
            LIMIT 10
            """,
            (query_fts5,),
        ).fetchall()
    else:
        rows = conn.execute(
            """
            SELECT cps, name, tts FROM codepoint_sequence_porter
            WHERE codepoint_sequence_porter MATCH ?
            ORDER BY rank
            LIMIT 10
            """,
            (query_fts5,),
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
        # print() raise UnicodeEncodeError when it encounter a surrogate.
        # So we do not use print() and write the bytes to stdout directly.
        #
        # However, even though we can write a UTF-8 encoded surrogate,
        # Alfred does not handle it very well.
        # We no longer do that.
        bytes_ = json.dumps({"items": items}, ensure_ascii=False).encode(
            "utf-8", errors="surrogatepass"
        )
        sys.stdout.buffer.write(bytes_)


main()
