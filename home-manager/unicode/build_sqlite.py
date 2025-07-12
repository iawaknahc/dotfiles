import os
import sqlite3
import sys
import xml.etree.ElementTree as ET
from collections.abc import Callable
from contextlib import closing
from dataclasses import dataclass
from functools import cached_property


@dataclass
class CodepointSequence:
    codepoints: list[int]
    name: str
    tts: str | None

    @cached_property
    def cps(self) -> str:
        return codepoints_to_cps(self.codepoints)


@dataclass
class Annotation:
    codepoints: list[int]
    tts: str

    @cached_property
    def cps(self) -> str:
        return codepoints_to_cps(self.codepoints)


def get_repertoire(tree: ET.ElementTree) -> ET.Element:
    el = tree.find("{http://www.unicode.org/ns/2003/ucd/1.0}repertoire")
    assert el is not None
    return el


def get_named_sequences(tree: ET.ElementTree) -> list[ET.Element]:
    els = tree.findall(".//{http://www.unicode.org/ns/2003/ucd/1.0}named-sequence")
    assert len(els) > 100
    return els


def get_standardized_variants(tree: ET.ElementTree) -> list[ET.Element]:
    els = tree.findall(
        ".//{http://www.unicode.org/ns/2003/ucd/1.0}standardized-variant"
    )
    assert len(els) > 100
    return els


def get_annotations(tree: ET.ElementTree) -> list[ET.Element]:
    els = tree.findall(".//annotation[@type='tts']")
    assert len(els) > 100
    return els


def notation_to_codepoint(notation: str) -> int:
    return int(notation, base=16)


def codepoint_to_notation(codepoint: int) -> str:
    return f"{codepoint:04X}"


def codepoints_to_cps(codepoints: list[int]) -> str:
    return " ".join([codepoint_to_notation(cp) for cp in codepoints])


def cps_to_codepoints(cps: str) -> list[int]:
    return [int(cp, base=16) for cp in cps.strip().split(" ")]


def get_codepoint_name(codepoint: int, el: ET.Element) -> str:
    na = el.attrib.get("na")
    na1 = el.attrib.get("na1")
    name_alias = el.find(
        "{http://www.unicode.org/ns/2003/ucd/1.0}name-alias[@type!='abbreviation']"
    )
    notation = codepoint_to_notation(codepoint=codepoint)
    if na is not None and na != "":
        return na.replace("#", notation)
    elif na1 is not None and na1 != "":
        return na1.replace("#", notation)
    elif name_alias is not None:
        return name_alias.attrib["alias"].replace("#", notation)
    elif codepoint >= 0xE000 and codepoint <= 0xF8FF:
        return "Private Use Area-#".replace("#", notation)
    elif codepoint >= 0xF0000 and codepoint <= 0xFFFFD:
        return "Plane 15 Private Use Area-#".replace("#", notation)
    elif codepoint >= 0x100000 and codepoint <= 0x10FFFD:
        return "Plane 16 Private Use Area-#".replace("#", notation)
    elif codepoint >= 0xD800 and codepoint <= 0xDB7F:
        return "High Surrogate-#".replace("#", notation)
    elif codepoint >= 0xDB80 and codepoint <= 0xDBFF:
        return "Private Use High Surrogate-#".replace("#", notation)
    elif codepoint >= 0xDC00 and codepoint <= 0xDFFF:
        return "Low Surrogate-#".replace("#", notation)
    else:
        raise ValueError(f"no idea how to handle {notation}")


def parse_ucd_line(line: str) -> list[str] | None:
    line = line.strip()
    if line == "" or line.startswith("#"):
        return None

    comment = line.find("#")
    if comment > -1:
        line = line[:comment]

    fields = [field.strip() for field in line.split(";")]
    return fields


def parse_emoji_sequences_txt(
    path_to_file: str, get_tts: Callable[[list[int]], str | None]
) -> list[CodepointSequence]:
    emoji_sequences = []
    with open(path_to_file, "r") as f:
        for line in f:
            fields = parse_ucd_line(line)
            if fields is None:
                continue
            cps = fields[0]
            typ_ = fields[1]
            # Basic_Emoji is either:
            #
            # - Plain code point - Already handled when we parse the UCD XML
            # - Code point range - Already handled when we parse the UCD XML
            # - emoji_presentation_sequence - to be handled when we parse emoji-variation-sequences.txt
            # - text_presentation_sequence - to be handled when we parse emoji-variation-sequences.txt
            #
            # Thus we skip it.
            if typ_ == "Basic_Emoji":
                continue
            # Emoji_Keycap_Sequence is included in named-sequence.
            # Thus we skip it.
            if typ_ == "Emoji_Keycap_Sequence":
                continue
            name = fields[2]
            list_of_codepoints = cps_to_codepoints(cps)
            emoji_sequences.append(
                CodepointSequence(
                    codepoints=list_of_codepoints,
                    name=name,
                    tts=get_tts(list_of_codepoints),
                )
            )
    return emoji_sequences


def parse_emoji_variation_sequences_txt(
    path_to_file: str,
    get_codepoint_by_cps: Callable[[str], CodepointSequence],
) -> list[CodepointSequence]:
    emoji_variation_sequences = []
    with open(path_to_file, "r") as f:
        for line in f:
            fields = parse_ucd_line(line)
            if fields is None:
                continue
            cps = fields[0]
            desc = fields[1]
            list_of_codepoints = cps_to_codepoints(cps)
            assert len(list_of_codepoints) == 2
            codepoint = get_codepoint_by_cps(codepoints_to_cps([list_of_codepoints[0]]))
            name = f"{codepoint.name} {desc}"
            tts = None
            if codepoint.tts is not None:
                tts = f"{codepoint.tts} {desc}"
            emoji_variation_sequences.append(
                CodepointSequence(codepoints=list_of_codepoints, name=name, tts=tts)
            )
    return emoji_variation_sequences


def parse_emoji_zwj_sequences_txt(
    path_to_file: str,
    get_tts: Callable[[list[int]], str | None],
) -> list[CodepointSequence]:
    emoji_zwj_sequences = []
    with open(path_to_file, "r") as f:
        for line in f:
            fields = parse_ucd_line(line)
            if fields is None:
                continue
            cps = fields[0]
            type_ = fields[1]
            assert type_ == "RGI_Emoji_ZWJ_Sequence"
            list_of_codepoints = cps_to_codepoints(cps)
            name = fields[2]
            tts = get_tts(list_of_codepoints)
            emoji_zwj_sequences.append(
                CodepointSequence(codepoints=list_of_codepoints, name=name, tts=tts)
            )
    return emoji_zwj_sequences


def expand_char(
    el: ET.Element, get_tts: Callable[[list[int]], str | None]
) -> list[CodepointSequence]:
    try:
        notation = el.attrib["cp"]
        cp = notation_to_codepoint(notation)
        name = get_codepoint_name(cp, el)
        tts = get_tts([cp])
        return [CodepointSequence(codepoints=[cp], name=name, tts=tts)]
    except KeyError:
        codepoints = []
        first_cp = notation_to_codepoint(el.attrib["first-cp"])
        last_cp = notation_to_codepoint(el.attrib["last-cp"])
        for i in range(first_cp, last_cp + 1):
            notation = codepoint_to_notation(i)
            name = get_codepoint_name(i, el)
            tts = get_tts([i])
            codepoints.append(CodepointSequence(codepoints=[i], name=name, tts=tts))
        return codepoints


def process_repertoire(
    repertoire: ET.Element, get_tts: Callable[[list[int]], str | None]
) -> list[CodepointSequence]:
    codepoints = []
    for el in repertoire:
        tag = el.tag
        if tag == "{http://www.unicode.org/ns/2003/ucd/1.0}char":
            codepoints.extend(expand_char(el, get_tts))
        elif tag == "{http://www.unicode.org/ns/2003/ucd/1.0}reserved":
            # They are not really defined, skip them.
            pass
        elif tag == "{http://www.unicode.org/ns/2003/ucd/1.0}noncharacter":
            # They are defined as noncharacter, skip them.
            pass
        elif tag == "{http://www.unicode.org/ns/2003/ucd/1.0}surrogate":
            codepoints.extend(expand_char(el, get_tts))
        else:
            raise ValueError(f"no idea how to handle {tag}")
    return codepoints


def process_named_sequences(els: list[ET.Element]) -> list[CodepointSequence]:
    named_sequences = []
    for el in els:
        name = el.attrib["name"]
        cps = el.attrib["cps"]
        named_sequences.append(
            CodepointSequence(codepoints=cps_to_codepoints(cps), name=name, tts=None)
        )
    return named_sequences


def process_standardized_variants(
    els: list[ET.Element],
    get_codepoint_by_cps: Callable[[str], CodepointSequence],
):
    standardized_variants = []
    for el in els:
        cps = el.attrib["cps"]
        desc = el.attrib["desc"]
        # Skip emoji sequence here.
        # We will process emoji data separately.
        if desc == "emoji style" or desc == "text style":
            continue
        list_of_codepoints = cps_to_codepoints(cps)
        # By observation, standardized-variant always has 2 code points where the 1st code point is the base,
        # while the 2nd code point is a modifier.
        assert len(list_of_codepoints) == 2
        codepoint = get_codepoint_by_cps(codepoints_to_cps([list_of_codepoints[0]]))
        name = f"{codepoint.name} {desc}"
        tts = None
        if codepoint.tts is not None:
            tts = f"{codepoint.tts} {desc}"
        standardized_variants.append(
            CodepointSequence(codepoints=list_of_codepoints, name=name, tts=tts)
        )
    return standardized_variants


def process_annotations(
    els: list[ET.Element],
) -> list[Annotation]:
    annotations = []
    for el in els:
        cp_str = el.attrib["cp"]
        tts = el.text or ""
        codepoints = [ord(cp) for cp in cp_str]
        annotations.append(Annotation(codepoints=codepoints, tts=tts))
    return annotations


def insert_codepoint_sequences(
    conn: sqlite3.Connection, codepoint_sequences: list[CodepointSequence]
):
    codepoint_sequence_values = [
        (cp.cps, cp.name, cp.tts) for cp in codepoint_sequences
    ]
    codepoint_sequence_fts5_values = [
        (cp.cps, cp.name, cp.tts) for cp in codepoint_sequences
    ]

    with conn:
        conn.execute("""
            CREATE TABLE codepoint_sequence (
                cps        TEXT UNIQUE NOT NULL,
                name       TEXT NOT NULL,
                tts        TEXT
            );
        """)
        conn.execute("""
            CREATE VIRTUAL TABLE codepoint_sequence_fts5 USING fts5(
                cps,
                name,
                tts,
                tokenize = "trigram"
            );
        """)
        conn.executemany(
            """
            INSERT INTO codepoint_sequence (cps, name, tts) VALUES (?, ?, ?);
        """,
            codepoint_sequence_values,
        )
        conn.executemany(
            """
            INSERT INTO codepoint_sequence_fts5 (cps, name, tts) VALUES (?, ?, ?);
            """,
            codepoint_sequence_fts5_values,
        )


def make_get_tts(annotations: list[Annotation]) -> Callable[[list[int]], str | None]:
    annotation_by_key: dict[str, Annotation] = {}
    for a in annotations:
        annotation_by_key[a.cps] = a

    def get_tts(codepoints: list[int]) -> str | None:
        key = codepoints_to_cps(codepoints)
        annotation = annotation_by_key.get(key)
        if annotation is None:
            return None
        return annotation.tts

    return get_tts


def make_get_codepoint_by_cps(
    codepoints: list[CodepointSequence],
) -> Callable[[str], CodepointSequence]:
    codepoint_by_cps: dict[str, CodepointSequence] = {}
    for c in codepoints:
        assert len(c.codepoints) == 1
        codepoint_by_cps[c.cps] = c

    def get_codepoint_by_cps(cps: str) -> CodepointSequence:
        return codepoint_by_cps[cps]

    return get_codepoint_by_cps


def main():
    ucd_nounihan_flat_xml = sys.argv[1]
    ucd_directory = sys.argv[2]
    cldr_directory = sys.argv[3]
    sqlite3_database_file = sys.argv[4]

    ucd_emoji_emoji_sequences_txt = os.path.join(
        ucd_directory, "./emoji/emoji-sequences.txt"
    )
    ucd_emoji_emoji_variation_sequences_txt = os.path.join(
        ucd_directory, "./emoji/emoji-variation-sequences.txt"
    )
    ucd_emoji_emoji_zwj_sequences_txt = os.path.join(
        ucd_directory, "./emoji/emoji-zwj-sequences.txt"
    )
    cldr_common_annotations_en_xml = os.path.join(
        cldr_directory, "./common/annotations/en.xml"
    )
    cldr_common_annotationsDerived_en_xml = os.path.join(
        cldr_directory, "./common/annotationsDerived/en.xml"
    )

    annotations_0 = process_annotations(
        get_annotations(ET.parse(cldr_common_annotations_en_xml))
    )
    annotations_1 = process_annotations(
        get_annotations(ET.parse(cldr_common_annotationsDerived_en_xml))
    )
    annotations = annotations_0 + annotations_1
    get_tts = make_get_tts(annotations)

    tree = ET.parse(ucd_nounihan_flat_xml)
    codepoints = process_repertoire(get_repertoire(tree), get_tts)

    get_codepoint_by_cps = make_get_codepoint_by_cps(codepoints)

    named_sequences = process_named_sequences(get_named_sequences(tree))
    standardized_variants = process_standardized_variants(
        get_standardized_variants(tree), get_codepoint_by_cps
    )
    emoji_sequences = parse_emoji_sequences_txt(ucd_emoji_emoji_sequences_txt, get_tts)
    emoji_variant_sequences = parse_emoji_variation_sequences_txt(
        ucd_emoji_emoji_variation_sequences_txt, get_codepoint_by_cps
    )
    emoji_zwj_sequences = parse_emoji_zwj_sequences_txt(
        ucd_emoji_emoji_zwj_sequences_txt, get_tts
    )
    codepoint_sequences = (
        codepoints
        + named_sequences
        + standardized_variants
        + emoji_sequences
        + emoji_variant_sequences
        + emoji_zwj_sequences
    )

    with closing(sqlite3.connect(sqlite3_database_file, autocommit=False)) as conn:
        insert_codepoint_sequences(conn, codepoint_sequences)


if __name__ == "__main__":
    main()
