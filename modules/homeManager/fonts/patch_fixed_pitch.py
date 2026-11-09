"""Mark a font as fixed-pitch so that CoreText reports it as monospace.

CoreText sets kCTFontTraitMonoSpace from the `isFixedPitch` flag of the font.
Emacs (NS build) relies on that trait: for a monospace font, a glyph whose
advance is N times the space width is drawn exactly N space widths wide.
That keeps 1 em CJK glyphs aligned to 2 columns at every font size.

The script detects every font format it knows about, but only patches the
formats where the patched font was verified to be reported as monospace by
CoreText. Anything else is rejected with an explanation, instead of producing
a font that may silently not work. This script cannot ask CoreText itself,
so the supported formats below are the result of manual testing.

Usage:
    python patch_fixed_pitch.py --check FONT...
    python patch_fixed_pitch.py INPUT OUTPUT
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import cast

from fontTools.ttLib import TTCollection, TTFont
from fontTools.ttLib.tables._n_a_m_e import NameRecord

# The first 4 bytes of a font file, and what they mean.
MAGIC_SFNT_TRUETYPE = b"\x00\x01\x00\x00"
MAGIC_SFNT_CFF = b"OTTO"
MAGIC_COLLECTION = b"ttcf"
UNSUPPORTED_MAGIC: dict[bytes, tuple[str, str]] = {
    b"true": (
        "Apple TrueType sfnt ('true' header)",
        (
            "This is a legacy Apple variant of the TrueType header. No font in use has it. "
            "It is probably safe to treat it like a normal TrueType font, "
            "but that has not been tested."
        ),
    ),
    b"typ1": (
        "Apple sfnt-wrapped PostScript Type 1 font ('typ1' header)",
        (
            "This is a legacy Apple format that fontTools cannot edit as OpenType. "
            "Convert the font to OpenType first."
        ),
    ),
    b"wOFF": (
        "WOFF web font",
        (
            "WOFF is a compressed wrapper around an OpenType font. Decompress it first: "
            "load it with fontTools.ttLib.TTFont, set `font.flavor = None`, and save it. "
            "Then run this script on the result."
        ),
    ),
    b"wOF2": (
        "WOFF2 web font",
        (
            "WOFF2 is a compressed wrapper around an OpenType font. Decompress it first, "
            "e.g. `fonttools ttLib.woff2 decompress FONT.woff2`, "
            "then run this script on the result."
        ),
    ),
    b"\x00\x00\x01\x00": (
        "Mac resource-fork font (.dfont / suitcase)",
        (
            "This is a legacy Mac container, not an OpenType file. "
            "Extract the OpenType font from it first (e.g. with fondu)."
        ),
    ),
    b"STAR": (
        "BDF bitmap font",
        ("BDF is an X11 bitmap format with no OpenType tables. It cannot be patched."),
    ),
    b"\x01fcp": (
        "PCF bitmap font",
        ("PCF is an X11 bitmap format with no OpenType tables. It cannot be patched."),
    ),
}
TYPE1_PREFIXES: tuple[bytes, ...] = (b"\x80\x01", b"%!PS-AdobeFont", b"%!FontType1")

# Each pair was verified by patching a real font and checking kCTFontTraitMonoSpace:
#   TrueType static:      Jigmo, Noto Sans Armenian (Apple's .ttc)
#   CFF name-keyed static: Noto Music
#   CFF2 variable:        Noto Sans Mono CJK VF (.ttc)
SUPPORTED_OUTLINE_VARIATIONS = {
    ("TrueType (glyf)", "static"),
    ("CFF, name-keyed", "static"),
    ("CFF2", "variable"),
}
# sbix was verified with Apple Color Emoji.
SUPPORTED_COLORS = {"none", "sbix"}

# Fonts built by Apple (e.g. in /System/Library/Fonts) carry these private
# entries in the `meta` table. CoreText appears to read precomputed attributes
# from them: with them present, setting isFixedPitch had no effect on
# Apple Color Emoji and Noto Sans Armenian. Removing them made the flag work.
APPLE_METADATA_TAGS = ("appl", "bild")

OUTLINE_VARIATION_EXPLANATIONS: dict[tuple[str, str], str] = {
    ("TrueType (glyf)", "variable"): (
        "CoreText did not report a patched variable TrueType font as monospace. "
        "This was observed with Noto Sans (axes wght and wdth): it stayed non-monospace "
        "until the wght axis was removed, while removing only the wdth axis did not help. "
        "The exact rule is unknown, so this format is rejected."
    ),
    ("CFF2", "static"): (
        "No font in use is a static CFF2 font, so it has not been tested with CoreText."
    ),
}

OUTLINE_EXPLANATIONS: dict[str, str] = {
    "CFF, CID-keyed": (
        "CoreText ignores isFixedPitch in CID-keyed CFF fonts. This was verified with "
        "Source Han Mono 1.002: the flag had no effect, in both `post` and the CFF Top DICT. "
        "Converting the outlines to CFF2 first makes the flag work "
        "(fontTools.cffLib.CFFToCFF2.convertCFFToCFF2), "
        "but no font in use needs that, so it is not implemented."
    ),
    "CFF, multiple fonts in one FontSet": (
        "The CFF table holds more than one font. OpenType requires exactly one, "
        "so this font is malformed or very unusual."
    ),
    "both TrueType (glyf) and CFF outlines": (
        "The font contains more than one kind of outline table. "
        "It is unclear which one CoreText would use, so the font is rejected."
    ),
    "none (bitmap only)": (
        "The font has no outline table, only bitmap strikes. "
        "No font in use is like that, and it has not been tested with CoreText."
    ),
    "none (no glyph data)": (
        "The font has neither outlines nor bitmaps. It is probably malformed."
    ),
}
COLOR_EXPLANATION = (
    "No font in use has these color tables, so setting the flag on such a font "
    "has not been tested. The patch would probably work, "
    "since it does not touch color tables."
)


class UnsupportedFontError(Exception):
    pass


@dataclass
class Face:
    """The detected format of one face in a font file."""

    index: int
    name: str
    outline: str
    variation: str
    color: str
    has_apple_metadata: bool
    has_post: bool
    is_fixed_pitch: bool

    def describe(self) -> str:
        apple = ", Apple metadata" if self.has_apple_metadata else ""
        return f"outline={self.outline}, {self.variation}, color={self.color}{apple}"

    def problems(self) -> list[str]:
        problems: list[str] = []
        if self.outline in OUTLINE_EXPLANATIONS:
            reason = OUTLINE_EXPLANATIONS[self.outline]
            problems.append(f"Outline format is {self.outline}. {reason}")
        elif (self.outline, self.variation) not in SUPPORTED_OUTLINE_VARIATIONS:
            reason = OUTLINE_VARIATION_EXPLANATIONS.get(
                (self.outline, self.variation), "This format is not supported."
            )
            problems.append(f"Format is {self.outline}, {self.variation}. {reason}")
        if self.color not in SUPPORTED_COLORS:
            problems.append(f"Color tables: {self.color}. {COLOR_EXPLANATION}")
        if not self.has_post:
            problems.append(
                "The font has no `post` table, which is where isFixedPitch lives. "
                "OpenType requires that table, so the font is malformed."
            )
        return problems


def detect_container(path: Path) -> str:
    with path.open("rb") as f:
        head = f.read(16)
    if head.startswith(TYPE1_PREFIXES):
        raise UnsupportedFontError(
            f"{path} is a PostScript Type 1 font (.pfb/.pfa), not an OpenType font.\n"
            "fontTools cannot patch it as OpenType. Convert it to OpenType first."
        )
    magic = head[:4]
    if magic == MAGIC_SFNT_TRUETYPE:
        return "single (TrueType-flavored)"
    if magic == MAGIC_SFNT_CFF:
        return "single (CFF-flavored)"
    if magic == MAGIC_COLLECTION:
        return "collection"
    if magic in UNSUPPORTED_MAGIC:
        kind, reason = UNSUPPORTED_MAGIC[magic]
        raise UnsupportedFontError(f"{path} is a {kind}.\n{reason}")
    raise UnsupportedFontError(
        f"{path} does not look like any known font format "
        f"(first bytes: {head[:8]!r}). It is not OpenType, WOFF, Type 1, or a bitmap font."
    )


def detect_outline(font: TTFont) -> str:
    has_glyf = "glyf" in font
    has_cff = "CFF " in font
    has_cff2 = "CFF2" in font
    if sum([has_glyf, has_cff, has_cff2]) > 1:
        return "both TrueType (glyf) and CFF outlines"
    if has_glyf:
        return "TrueType (glyf)"
    if has_cff2:
        return "CFF2"
    if has_cff:
        cff = font["CFF "].cff
        if len(cff.fontNames) != 1:
            return "CFF, multiple fonts in one FontSet"
        # A CID-keyed CFF font declares its character collection in ROS
        # (Registry-Ordering-Supplement). A name-keyed one does not.
        if hasattr(cff.topDictIndex[0], "ROS"):
            return "CFF, CID-keyed"
        return "CFF, name-keyed"
    if any(tag in font for tag in ("EBDT", "bdat", "CBDT", "sbix")):
        return "none (bitmap only)"
    return "none (no glyph data)"


def detect_face(index: int, font: TTFont) -> Face:
    color_tags = [
        tag.strip() for tag in ("sbix", "CBDT", "COLR", "SVG ") if tag in font
    ]
    has_post = "post" in font
    return Face(
        index=index,
        name=font["name"].getDebugName(6) or font["name"].getDebugName(4) or "?",
        outline=detect_outline(font),
        variation="variable" if "fvar" in font else "static",
        color=", ".join(color_tags) or "none",
        has_apple_metadata="meta" in font
        and any(
            tag in cast(dict[str, object], font["meta"].data)
            for tag in APPLE_METADATA_TAGS
        ),
        has_post=has_post,
        is_fixed_pitch=has_post and bool(font["post"].isFixedPitch),  # ty: ignore[unresolved-attribute]
    )


def load_faces(
    path: Path, *, lazy: bool
) -> tuple[str, TTCollection | None, list[TTFont]]:
    container = detect_container(path)
    if container == "collection":
        collection = TTCollection(path, lazy=lazy)
        return container, collection, list(collection.fonts)
    return container, None, [TTFont(path, lazy=lazy)]


def check(path: Path, fonts: list[TTFont]) -> list[Face]:
    """Detect every face, and raise if any of them is not supported."""
    faces = [detect_face(i, font) for i, font in enumerate(fonts)]
    # Faces in a collection usually share the same problems. Report each once.
    affected: dict[str, list[Face]] = {}
    for face in faces:
        for problem in face.problems():
            affected.setdefault(problem, []).append(face)
    report: list[str] = []
    for problem, bad_faces in affected.items():
        if len(faces) == 1:
            where = f"{bad_faces[0].name}"
        elif len(bad_faces) == len(faces):
            where = f"all {len(faces)} faces"
        else:
            where = ", ".join(f"face {f.index} ({f.name})" for f in bad_faces)
        report.append(f"  {where}: {problem}")
    if report:
        raise UnsupportedFontError(
            f"{path} is not supported:\n" + "\n".join(report) + "\n"
            "Nothing was written. To support a new format, test with CoreText that the "
            "patched font is reported as monospace, then add it to the SUPPORTED_* sets."
        )
    return faces


def patch(font: TTFont, face: Face) -> None:
    font["post"].isFixedPitch = 1  # ty: ignore[unresolved-attribute]
    if face.outline == "CFF, name-keyed":
        # The CFF Top DICT has its own copy of the flag. Keep the two consistent.
        font["CFF "].cff.topDictIndex[0].isFixedPitch = 1
    if face.has_apple_metadata:
        # CoreText trusts the attributes cached in these entries over the flag.
        for tag in APPLE_METADATA_TAGS:
            cast(dict[str, object], font["meta"].data).pop(tag, None)


# name table IDs, see https://learn.microsoft.com/typography/opentype/spec/name
NAME_ID_UNIQUE = 3
NAME_ID_FULL = 4
NAME_ID_POSTSCRIPT = 6
NAME_ID_MAC_FULL = 18
NAME_ID_VARIATIONS_POSTSCRIPT_PREFIX = 25
FAMILY_NAME_IDS = (1, 16, 21)  # family, typographic family, WWS family
FULL_NAME_IDS = (NAME_ID_FULL, NAME_ID_MAC_FULL)
POSTSCRIPT_NAME_MAX_LENGTH = 63
NO_NAME_ID = 0xFFFF


def rename_postscript(name: str, suffix: str) -> str:
    """Insert SUFFIX after the family part: Family-Style -> FamilySUFFIX-Style."""
    family, dash, style = name.partition("-")
    return f"{family}{suffix}{dash}{style}"


def postscript_name_ids(font: TTFont) -> set[int]:
    ids = {NAME_ID_POSTSCRIPT, NAME_ID_VARIATIONS_POSTSCRIPT_PREFIX}
    if "fvar" in font:
        # Each named instance of a variable font (e.g. Medium, Bold)
        # has its own PostScript name.
        ids |= {
            i.postscriptNameID
            for i in font["fvar"].instances
            if i.postscriptNameID != NO_NAME_ID
        }
    return ids


def rename(
    path: Path, font: TTFont, face: Face, suffix: str, seen: set[int]
) -> dict[str, str]:
    """Give FONT new family and PostScript names. Return old -> new PostScript names.

    Faces in a collection may share table objects. SEEN holds the ids of tables
    already renamed, so that a shared table does not get the suffix twice.
    """
    name_table = font["name"]
    if id(name_table) in seen:
        return {}
    seen.add(id(name_table))
    ps_ids = postscript_name_ids(font)
    renamed: dict[str, str] = {}

    def family_of(record) -> str | None:
        # The family that a full name starts with, from the same platform and language.
        for name_id in (16, 1):
            family = name_table.getName(
                name_id, record.platformID, record.platEncID, record.langID
            )
            if family is not None:
                return family.toUnicode()
        return None

    old_ps_by_key = {
        (r.platformID, r.platEncID, r.langID): r.toUnicode()
        for r in name_table.names
        if r.nameID == NAME_ID_POSTSCRIPT
    }
    # Compute every new string before changing anything,
    # because full names are derived from the old family names.
    updates: list[tuple[NameRecord, str]] = []
    for record in name_table.names:
        old = record.toUnicode()
        if record.nameID in FAMILY_NAME_IDS:
            new = f"{old} {suffix}"
        elif record.nameID in FULL_NAME_IDS:
            family = family_of(record)
            if family is None or not old.startswith(family):
                raise UnsupportedFontError(
                    f"{path}: face {face.index} ({face.name}): full name {old!r} "
                    f"does not start with its family name {family!r}, so it is unclear "
                    "where to insert the suffix. Nothing was written."
                )
            new = f"{family} {suffix}{old[len(family) :]}"
        elif record.nameID in ps_ids:
            new = rename_postscript(old, suffix)
            if len(new) > POSTSCRIPT_NAME_MAX_LENGTH:
                raise UnsupportedFontError(
                    f"{path}: face {face.index} ({face.name}): the new PostScript name "
                    f"{new!r} is longer than {POSTSCRIPT_NAME_MAX_LENGTH} characters, "
                    "the limit in the OpenType spec. Use a shorter suffix."
                )
            renamed[old] = new
        elif record.nameID == NAME_ID_UNIQUE:
            # The unique ID usually embeds the PostScript name. Make it unique too.
            old_ps = old_ps_by_key.get(
                (record.platformID, record.platEncID, record.langID)
            )
            if old_ps is not None and old_ps in old:
                new = old.replace(old_ps, rename_postscript(old_ps, suffix))
            else:
                new = f"{old};{suffix}"
        else:
            continue
        updates.append((record, new))
    for record, new in updates:
        record.string = new

    if "CFF " in font and id(font["CFF "]) not in seen:
        seen.add(id(font["CFF "]))
        # A name-keyed CFF table stores the PostScript name too.
        cff = font["CFF "].cff
        cff.fontNames = [rename_postscript(n, suffix) for n in cff.fontNames]
    return renamed


def check_renamed(path: Path, renamed: list[dict[str, str]]) -> None:
    """Make sure no new PostScript name collides with an old or another new one."""
    olds = {old for mapping in renamed for old in mapping}
    news: dict[str, str] = {}
    for mapping in renamed:
        for old, new in mapping.items():
            if new in olds:
                raise UnsupportedFontError(
                    f"{path}: the new PostScript name {new!r} already exists in the font. "
                    "Use a different suffix. Nothing was written."
                )
            if news.setdefault(new, old) != old:
                raise UnsupportedFontError(
                    f"{path}: both {news[new]!r} and {old!r} would be renamed to {new!r}. "
                    "Nothing was written."
                )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument(
        "--check", action="store_true", help="only detect and report; write nothing"
    )
    parser.add_argument(
        "--family-suffix",
        metavar="SUFFIX",
        help=(
            "rename the patched font so it can be installed next to the original, "
            "e.g. RealMono: 'Jigmo' -> 'Jigmo RealMono', "
            "'NotoSansMonoCJKhk-Regular' -> 'NotoSansMonoCJKhkRealMono-Regular'"
        ),
    )
    parser.add_argument("paths", nargs="+", type=Path)
    args = parser.parse_args()

    if not args.check and len(args.paths) != 2:
        parser.error("patching takes exactly INPUT and OUTPUT")
    if args.family_suffix is not None and not (
        args.family_suffix.isascii() and args.family_suffix.isalnum()
    ):
        # It goes into PostScript names, which allow neither spaces nor hyphens here.
        parser.error("--family-suffix must contain only ASCII letters and digits")

    inputs = args.paths if args.check else args.paths[:1]
    failed = False
    for path in inputs:
        try:
            container, collection, fonts = load_faces(path, lazy=args.check)
            faces = check(path, fonts)
        except UnsupportedFontError as e:
            print(f"error: {e}", file=sys.stderr)
            failed = True
            continue
        print(f"{path}: {container}, {len(faces)} face(s)")
        for face in faces:
            state = "already fixed-pitch" if face.is_fixed_pitch else "not fixed-pitch"
            print(f"  face {face.index} ({face.name}): {face.describe()}, {state}")
        if args.check:
            continue

        output: Path = args.paths[1]
        if output.resolve() == path.resolve():
            print("error: OUTPUT must be different from INPUT", file=sys.stderr)
            return 2
        renamed: list[dict[str, str]] = []
        seen: set[int] = set()
        try:
            for font, face in zip(fonts, faces, strict=True):
                patch(font, face)
                if args.family_suffix is not None:
                    renamed.append(rename(path, font, face, args.family_suffix, seen))
            check_renamed(path, renamed)
        except UnsupportedFontError as e:
            print(f"error: {e}", file=sys.stderr)
            return 1
        for mapping in renamed:
            for old, new in mapping.items():
                print(f"  renamed {old} -> {new}")
        if collection is not None:
            collection.save(output)
        else:
            fonts[0].save(output)
        print(f"wrote {output}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
