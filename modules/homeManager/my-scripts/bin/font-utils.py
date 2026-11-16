#!/usr/bin/env python3
import argparse
import dataclasses
import fractions
import io
import math
import pathlib
from typing import Self, cast

import fontTools.ttLib
import fontTools.ttLib.tables
import fontTools.ttLib.tables._c_m_a_p


@dataclasses.dataclass
class UnicodeRange:
    start: int
    end: int
    size: int

    def __init__(self, *, start: int, end: int):
        self.start = start
        self.end = end
        self.size = self.end - self.start + 1

    def combine_range(self, that: Self) -> Self | None:
        if self.end + 1 == that.start:
            return type(self)(start=self.start, end=that.end)
        return None

    def combine_codepoint(self, codepoint: int) -> Self | None:
        if self.end + 1 == codepoint:
            return type(self)(start=self.start, end=codepoint)
        return None

    def intersect(self, that: Self) -> Self | None:
        start = max(self.start, that.start)
        end = min(self.end, that.end)
        if start > end:
            return None
        return type(self)(start=start, end=end)

    def intersect_size(self, that: Self) -> int:
        r = self.intersect(that)
        if r is None:
            return 0
        return r.size

    def union(self, that: Self) -> Self | None:
        intersection = self.intersect(that)
        if intersection is None:
            return None
        return type(self)(
            start=min(self.start, that.start), end=max(self.end, that.end)
        )


@dataclasses.dataclass
class UnicodeBlockScriptStatistics:
    script_name: str
    count: int
    total: int


@dataclasses.dataclass
class UnicodeBlock:
    block_name: str
    range: UnicodeRange
    scripts: list[UnicodeBlockScriptStatistics]

    def __init__(self, *, block_name: str, range: UnicodeRange):
        self.block_name = block_name
        self.range = range
        self.scripts = []

    def __str__(self) -> str:
        buf = io.StringIO()
        print(
            f"{self.block_name} ({self.range.start:04X}..{self.range.end:04X}) size={self.range.size}",
            file=buf,
        )
        for script in self.scripts:
            print(
                f"  {script.script_name} {script.count}/{script.total} {script.count / script.total * 100:.0f}%",
                file=buf,
            )
        return buf.getvalue()

    def size(self) -> int:
        if len(self.scripts) > 0:
            return self.scripts[0].total
        return self.range.size


@dataclasses.dataclass
class UnicodeScript:
    script_name: str
    total_size: int
    ranges: list[UnicodeRange]

    def __str__(self) -> str:
        buf = io.StringIO()
        print(f"{self.script_name}", file=buf)
        for range in self.ranges:
            print(
                f"  {range.start:04X}..{range.end:04X} {range.size}/{self.total_size} {range.size / self.total_size * 100:.0f}%",
                file=buf,
            )
        return buf.getvalue()


def parse_ucd_file(filepath: pathlib.Path):
    """
    parse_ucd_file yields lines that are not comments.
    The end of line comment is excluded.
    The newline of each line is excluded.
    """
    with open(filepath.expanduser()) as f:
        for line0 in f:
            line1 = line0.rstrip()
            hash_index = line1.find("#")
            if hash_index >= 0:
                line2 = line1[0:hash_index]
            else:
                line2 = line1
            if line2 != "":
                yield line2


def parse_blocks_txt(blocks_txt: pathlib.Path) -> list[UnicodeBlock]:
    blocks: list[UnicodeBlock] = []
    for line in parse_ucd_file(blocks_txt):
        fields = line.split(";")
        fields = [field.strip() for field in fields]
        range_syntax = fields[0]
        block_name = fields[1]
        range_syntax_fields = range_syntax.split("..")
        range_start_inclusive = int(range_syntax_fields[0], base=16)
        range_end_inclusive = int(range_syntax_fields[1], base=16)
        block = UnicodeBlock(
            block_name=block_name,
            range=UnicodeRange(start=range_start_inclusive, end=range_end_inclusive),
        )
        blocks.append(block)
    return blocks


def parse_scripts_txt(scripts_txt: pathlib.Path) -> list[tuple[UnicodeRange, str]]:
    range_and_script_pairs: list[tuple[UnicodeRange, str]] = []
    for line in parse_ucd_file(scripts_txt):
        fields = line.split(";")
        fields = [field.strip() for field in fields]
        range_syntax_or_codepoint = fields[0]
        script_name = fields[1]
        range_syntax_fields = range_syntax_or_codepoint.split("..")
        if len(range_syntax_fields) == 2:
            range_start_inclusive = int(range_syntax_fields[0], base=16)
            range_end_inclusive = int(range_syntax_fields[1], base=16)
            unicode_range = UnicodeRange(
                start=range_start_inclusive, end=range_end_inclusive
            )
        elif len(range_syntax_fields) == 1:
            codepoint = int(range_syntax_fields[0], base=16)
            unicode_range = UnicodeRange(start=codepoint, end=codepoint)
        else:
            raise ValueError(f"malformed line: {line}")
        range_and_script_pairs.append((unicode_range, script_name))
    return range_and_script_pairs


def prepare_unicode_blocks(args: argparse.Namespace) -> list[UnicodeBlock]:
    blocks = parse_blocks_txt(
        pathlib.Path(args.unicode_directory) / "ucd" / "Blocks.txt"
    )
    range_and_script_pairs = parse_scripts_txt(
        pathlib.Path(args.unicode_directory) / "ucd" / "Scripts.txt"
    )
    for block in blocks:
        working_dict: dict[str, int] = {}
        for pair in range_and_script_pairs:
            intersection = block.range.intersect_size(pair[0])
            if intersection > 0:
                working_dict[pair[1]] = (
                    working_dict.setdefault(pair[1], 0) + intersection
                )
        items = [item for item in working_dict.items()]
        items = sorted(items, key=lambda pair: pair[1], reverse=True)

        total = 0
        for item in items:
            total += item[1]

        for item in items:
            block.scripts.append(
                UnicodeBlockScriptStatistics(
                    script_name=item[0],
                    count=item[1],
                    total=total,
                )
            )
    return blocks


def cmd_list_unicode_blocks(args: argparse.Namespace):
    blocks = prepare_unicode_blocks(args)
    for block in blocks:
        print(block, end="")


def prepare_unicode_scripts(args: argparse.Namespace) -> list[UnicodeScript]:
    range_and_script_pairs = parse_scripts_txt(
        pathlib.Path(args.unicode_directory) / "ucd" / "Scripts.txt"
    )

    range_and_script_pairs_combined: list[tuple[UnicodeRange, str]] = []
    for pair in range_and_script_pairs:
        if len(range_and_script_pairs_combined) == 0:
            range_and_script_pairs_combined.append(pair)
        else:
            did_combine = False
            last_pair = range_and_script_pairs_combined[-1]
            if last_pair[1] == pair[1]:
                combined_range = last_pair[0].combine_range(pair[0])
                if combined_range is not None:
                    range_and_script_pairs_combined[-1] = (combined_range, pair[1])
                    did_combine = True
            if not did_combine:
                range_and_script_pairs_combined.append(pair)

    scripts_set = set()
    for pair in range_and_script_pairs_combined:
        scripts_set.add(pair[1])

    scripts: list[UnicodeScript] = []
    for script_name in scripts_set:
        total = 0
        ranges: list[UnicodeRange] = []
        for pair in range_and_script_pairs_combined:
            if script_name == pair[1]:
                total += pair[0].size
                ranges.append(pair[0])
        scripts.append(
            UnicodeScript(
                script_name=script_name,
                total_size=total,
                ranges=ranges,
            )
        )
    scripts = sorted(scripts, key=lambda script: script.script_name)
    return scripts


def cmd_list_unicode_scripts(args: argparse.Namespace):
    scripts = prepare_unicode_scripts(args)
    for script in scripts:
        print(script, end="")


def codepoints_to_unicode_ranges(codepoints: list[int]) -> list[UnicodeRange]:
    out: list[UnicodeRange] = []
    for codepoint in codepoints:
        if len(out) == 0:
            out.append(UnicodeRange(start=codepoint, end=codepoint))
        else:
            combined_range = out[-1].combine_codepoint(codepoint)
            if combined_range is not None:
                out[-1] = combined_range
            else:
                out.append(UnicodeRange(start=codepoint, end=codepoint))
    return out


def prepare_fonts_ranges(raw_paths: list[str]) -> list[UnicodeRange]:
    overlapping_ranges: list[UnicodeRange] = []
    for path in raw_paths:
        path_to_font = pathlib.Path(path).expanduser()

        try:
            collection = fontTools.ttLib.TTCollection(str(path_to_font))
            font = collection.fonts[0]
        except fontTools.ttLib.TTLibError:
            font = fontTools.ttLib.TTFont(str(path_to_font))

        try:
            cmap: fontTools.ttLib.tables._c_m_a_p.table__c_m_a_p = font["cmap"]
        except KeyError:
            raise TypeError(f"cmap not found: {path_to_font}")

        target: fontTools.ttLib.tables._c_m_a_p.CmapSubtable | None = None
        if target is None:
            for table in cmap.tables:
                # platformID 3 means Windows
                # platEncID 10 means Unicode full repertoire
                # format 12 is a must when platformID == 3 and platEncID == 10.
                # See https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#windows-platform-platform-id--3
                if (
                    table.platformID == 3
                    and table.platEncID == 10
                    and table.format == 12
                ):
                    target = table
        if target is None:
            for table in cmap.tables:
                # platformID 3 means Windows
                # platEncID 1 means Unicode BMP
                # format 4 is a must when platformID == 3 and platEncID == 1.
                # See https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#windows-platform-platform-id--3
                if table.platformID == 3 and table.platEncID == 1 and table.format == 4:
                    target = table
        if target is None:
            raise TypeError(f"cmap not found: {path_to_font}")

        codepoint_to_name: dict[int, str] = target.cmap
        codepoints = list(codepoint_to_name.keys())
        codepoints = sorted(codepoints, key=lambda codepoint: codepoint)
        overlapping_ranges.extend(codepoints_to_unicode_ranges(codepoints))

    overlapping_ranges = sorted(
        overlapping_ranges, key=lambda range: (range.start, -range.end)
    )

    ranges: list[UnicodeRange] = []
    for r in overlapping_ranges:
        if len(ranges) == 0:
            ranges.append(r)
        else:
            union = ranges[-1].union(r)
            if union is not None:
                ranges[-1] = union
            else:
                ranges.append(r)

    for idx, r in enumerate(ranges):
        if idx > 0 and r.intersect(ranges[idx - 1]) is not None:
            raise TypeError("ranges must be non-overlapping")

    return ranges


def cmd_inspect_font_coverage_by_blocks(args: argparse.Namespace):
    blocks = prepare_unicode_blocks(args)
    ranges = prepare_fonts_ranges(args.fonts)

    block_coverages: list[tuple[UnicodeBlock, int]] = []
    for block in blocks:
        count = 0
        for range in ranges:
            count += block.range.intersect_size(range)
        block_coverages.append((block, count))

    for coverage in block_coverages:
        if coverage[1] > 0:
            print(
                f"{coverage[0].block_name} ({coverage[0].range.start:04X}..{coverage[0].range.end:04X}) {coverage[1]}/{coverage[0].size()} {coverage[1] / coverage[0].size() * 100:.0f}%"
            )


def cmd_inspect_font_coverage_by_scripts(args: argparse.Namespace):
    scripts = prepare_unicode_scripts(args)
    ranges = prepare_fonts_ranges(args.fonts)

    script_coverages: list[tuple[str, int, int, list[tuple[UnicodeRange, int]]]] = []
    for script in scripts:
        coverage_in_this_script: list[tuple[UnicodeRange, int]] = []
        count_in_this_script = 0
        for script_range in script.ranges:
            count_in_this_range = 0
            for font_range in ranges:
                size = script_range.intersect_size(font_range)
                count_in_this_range += size
                count_in_this_script += size
            coverage_in_this_script.append((script_range, count_in_this_range))
        script_coverages.append(
            (
                script.script_name,
                count_in_this_script,
                script.total_size,
                coverage_in_this_script,
            )
        )

    for coverage in script_coverages:
        if coverage[1] > 0:
            print(
                f"{coverage[0]} {coverage[1]}/{coverage[2]} {coverage[1] / coverage[2] * 100:.0f}%"
            )
            for range, count in coverage[3]:
                print(
                    f"  {range.start:04X}..{range.end:04X} {count}/{range.size} {count / range.size * 100:.0f}%"
                )


def load_font_faces(
    path: pathlib.Path,
) -> tuple[fontTools.ttLib.TTCollection | None, list[fontTools.ttLib.TTFont]]:
    # recalcBBoxes=False keeps the stored bounding boxes.
    # Otherwise, save() decompiles every glyph to recompute them, which takes minutes for CJK fonts.
    # patch_cjk_font_face does not change any coordinate, so the stored bounding boxes stay valid.
    with open(path, "rb") as f:
        magic = f.read(4)
    if magic == b"ttcf":
        # Do not use shareTables=True. Faces sharing a table object break in subtle ways.
        # For example, faces may share a post table without names, yet have different glyph orders,
        # because the glyph names are then derived from the cmap of each face.
        # Each face gets its own table objects, and TTCollection.save() shares identical tables again.
        collection = fontTools.ttLib.TTCollection(str(path), recalcBBoxes=False)
        return collection, list(collection.fonts)
    return None, [fontTools.ttLib.TTFont(str(path), recalcBBoxes=False)]


@dataclasses.dataclass
class ReferenceMetrics:
    """The metrics of the reference font, in em. descender is positive."""

    half_width: fractions.Fraction
    ascender: fractions.Fraction
    descender: fractions.Fraction
    line_gap: fractions.Fraction


def read_reference_metrics(path: pathlib.Path) -> ReferenceMetrics:
    _, fonts = load_font_faces(path)
    font = fonts[0]
    upm = font["head"].unitsPerEm  # ty: ignore[unresolved-attribute]
    cmap = font.getBestCmap()
    if cmap is None:
        raise ValueError(f"{path}: no Unicode cmap")
    space = cmap[0x20]
    hhea = font["hhea"]
    return ReferenceMetrics(
        half_width=fractions.Fraction(font["hmtx"][space][0], upm),
        ascender=fractions.Fraction(hhea.ascent, upm),
        descender=fractions.Fraction(-hhea.descent, upm),
        line_gap=fractions.Fraction(hhea.lineGap, upm),  # ty: ignore[unresolved-attribute]
    )


# Fonts built by Apple carry these private entries in the `meta` table.
# CoreText trusts the attributes cached in them over isFixedPitch.
APPLE_METADATA_TAGS = ("appl", "bild")


def check_cjk_font_face(path: pathlib.Path, index: int, font: fontTools.ttLib.TTFont):
    where = f"{path}: face {index} ({font['name'].getDebugName(4)})"
    has_glyf = "glyf" in font
    has_cff = "CFF " in font
    has_cff2 = "CFF2" in font
    is_variable = "fvar" in font
    # These are the formats where CoreText was verified to report the font as monospace
    # after setting isFixedPitch.
    # CoreText ignores isFixedPitch in CID-keyed CFF, and in some variable TrueType fonts.
    # For CFF2, CoreText was also verified to scale glyphs by head.unitsPerEm, not by FontMatrix.
    is_static_truetype = has_glyf and not has_cff and not has_cff2 and not is_variable
    is_variable_cff2 = has_cff2 and not has_glyf and not has_cff and is_variable
    if not (is_static_truetype or is_variable_cff2):
        raise ValueError(
            f"{where}: only static TrueType (glyf) and variable CFF2 fonts are supported"
        )
    if "MVAR" in font:
        raise ValueError(
            f"{where}: MVAR is not supported because it may vary the vertical metrics"
        )
    if "meta" in font and any(
        tag in cast(dict[str, object], font["meta"].data) for tag in APPLE_METADATA_TAGS
    ):
        raise ValueError(f"{where}: fonts with Apple metadata are not supported")


# The range of head.unitsPerEm allowed by the OpenType spec.
MIN_UNITS_PER_EM = 16
MAX_UNITS_PER_EM = 16384


def patch_cjk_font_face(
    path: pathlib.Path,
    index: int,
    font: fontTools.ttLib.TTFont,
    reference: ReferenceMetrics,
):
    """
    patch_cjk_font_face enlarges FONT so that a full-width glyph is as wide as 2 half-width glyphs
    of the reference font, and copies the vertical metrics of the reference font.

    It enlarges the font by lowering head.unitsPerEm, so that no coordinate has to change.
    Units per em is an integer, so the full-width glyph is only approximately as wide as intended.
    e.g. 1000 units per em becomes 833 instead of 1000/1.2, so a full-width glyph is 1.2005em.
    Emacs (NS build) draws a glyph of a monospace font N space widths wide, in whole pixels.
    The rounding error is too small to change the space width in pixels at any practical size.
    """
    where = f"{path}: face {index} ({font['name'].getDebugName(4)})"
    upm = font["head"].unitsPerEm  # ty: ignore[unresolved-attribute]
    cmap = font.getBestCmap()
    if cmap is None:
        raise ValueError(f"{where}: no Unicode cmap")
    hmtx = font["hmtx"]
    half = hmtx[cmap[0x20]][0]
    full = hmtx[cmap[0x4E00]][0]
    if full != 2 * half:
        raise ValueError(
            f"{where}: U+4E00 is {full} wide, which is not 2 times the width of U+0020 ({half})"
        )

    new_upm = round(full / (2 * reference.half_width))
    if not (MIN_UNITS_PER_EM <= new_upm <= MAX_UNITS_PER_EM):
        raise ValueError(f"{where}: the new units per em {new_upm} is out of range")
    font["head"].unitsPerEm = new_upm  # ty: ignore[unresolved-attribute]

    # Round down, so that this font never makes a line taller than the reference font does.
    ascender = math.floor(reference.ascender * new_upm)
    descender = math.floor(reference.descender * new_upm)
    line_gap = math.floor(reference.line_gap * new_upm)
    hhea = font["hhea"]
    hhea.ascent = ascender
    hhea.descent = -descender
    hhea.lineGap = line_gap  # ty: ignore[unresolved-attribute]
    os2 = font["OS/2"]
    os2.sTypoAscender = ascender  # ty: ignore[unresolved-attribute]
    os2.sTypoDescender = -descender  # ty: ignore[unresolved-attribute]
    os2.sTypoLineGap = line_gap  # ty: ignore[unresolved-attribute]
    os2.usWinAscent = ascender  # ty: ignore[unresolved-attribute]
    os2.usWinDescent = descender  # ty: ignore[unresolved-attribute]

    # CoreText reports the font as monospace with this flag.
    # Emacs (NS build) then draws a glyph whose advance is N times the space width
    # exactly N space widths wide.
    font["post"].isFixedPitch = 1  # ty: ignore[unresolved-attribute]

    print(f"face {index} ({font['name'].getDebugName(4)}):")
    print(
        f"  unitsPerEm {upm} -> {new_upm}, so U+4E00 is {float(fractions.Fraction(full, new_upm)):.4f}em wide"
    )
    print(f"  ascender={ascender} descender={-descender} lineGap={line_gap}")


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


def rename_font_face(
    path: pathlib.Path,
    index: int,
    font: fontTools.ttLib.TTFont,
    suffix: str,
) -> dict[str, str]:
    """
    rename_font_face gives FONT new family and PostScript names.
    It returns a dict from old PostScript names to new PostScript names.
    """
    where = f"{path}: face {index} ({font['name'].getDebugName(4)})"
    name_table = font["name"]

    postscript_name_ids = {NAME_ID_POSTSCRIPT, NAME_ID_VARIATIONS_POSTSCRIPT_PREFIX}
    if "fvar" in font:
        # Each named instance of a variable font (e.g. Medium, Bold) has its own PostScript name.
        for instance in font["fvar"].instances:
            if instance.postscriptNameID != NO_NAME_ID:
                postscript_name_ids.add(instance.postscriptNameID)

    def family_of(record) -> str | None:
        # The family that a full name starts with, from the same platform and language.
        for name_id in (16, 1):
            family = name_table.getName(
                name_id, record.platformID, record.platEncID, record.langID
            )
            if family is not None:
                return family.toUnicode()
        return None

    old_postscript_names = {
        (r.platformID, r.platEncID, r.langID): r.toUnicode()
        for r in name_table.names
        if r.nameID == NAME_ID_POSTSCRIPT
    }
    # Compute every new string before changing anything,
    # because full names are derived from the old family names.
    renamed: dict[str, str] = {}
    updates = []
    for record in name_table.names:
        old = record.toUnicode()
        if record.nameID in FAMILY_NAME_IDS:
            new = f"{old} {suffix}"
        elif record.nameID in FULL_NAME_IDS:
            family = family_of(record)
            # Compare case-insensitively, because some fonts differ only in case,
            # e.g. D2Coding has the family 'D2Coding ligature' and the full name 'D2Coding Ligature'.
            if family is None or not old.lower().startswith(family.lower()):
                raise ValueError(
                    f"{where}: full name {old!r} does not start with its family name {family!r}"
                )
            new = f"{old[: len(family)]} {suffix}{old[len(family) :]}"
        elif record.nameID in postscript_name_ids:
            new = rename_postscript(old, suffix)
            if len(new) > POSTSCRIPT_NAME_MAX_LENGTH:
                raise ValueError(
                    f"{where}: PostScript name {new!r} is longer than {POSTSCRIPT_NAME_MAX_LENGTH} characters"
                )
            renamed[old] = new
        elif record.nameID == NAME_ID_UNIQUE:
            # The unique ID usually embeds the PostScript name. Make it unique too.
            old_postscript_name = old_postscript_names.get(
                (record.platformID, record.platEncID, record.langID)
            )
            if old_postscript_name is not None and old_postscript_name in old:
                new = old.replace(
                    old_postscript_name, rename_postscript(old_postscript_name, suffix)
                )
            else:
                new = f"{old};{suffix}"
        else:
            continue
        updates.append((record, new))
    for record, new in updates:
        record.string = new
    return renamed


def cmd_patch_cjk_font(args: argparse.Namespace):
    suffix: str = args.family_suffix
    if not (suffix.isascii() and suffix.isalnum()):
        # It goes into PostScript names, which allow neither spaces nor hyphens here.
        raise ValueError("--family-suffix must contain only ASCII letters and digits")
    input_path = pathlib.Path(args.input).expanduser()
    output_path = pathlib.Path(args.output).expanduser()
    if input_path.resolve() == output_path.resolve():
        raise ValueError("OUTPUT must be different from INPUT")

    reference = read_reference_metrics(pathlib.Path(args.reference).expanduser())
    collection, fonts = load_font_faces(input_path)
    for index, font in enumerate(fonts):
        check_cjk_font_face(input_path, index, font)

    for index, font in enumerate(fonts):
        patch_cjk_font_face(input_path, index, font, reference)

    renamed: dict[str, str] = {}
    for index, font in enumerate(fonts):
        renamed |= rename_font_face(input_path, index, font, suffix)
    for new in renamed.values():
        if new in renamed:
            raise ValueError(
                f"{input_path}: the new PostScript name {new!r} already exists in the font"
            )
    for old, new in renamed.items():
        print(f"renamed {old} -> {new}")

    if collection is not None:
        collection.save(str(output_path), shareTables=True)
    else:
        fonts[0].save(str(output_path))
    print(f"wrote {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Some utilities on fonts",
    )
    parser.add_argument(
        "--unicode-directory",
        help="The path to Unicode directory",
        default="~/.nix-profile/share/unicode/18.0.0",
    )

    subcommand = parser.add_subparsers(required=True)

    list_unicode_blocks = subcommand.add_parser(
        "list-unicode-blocks",
        help="List Unicode blocks",
    )
    list_unicode_blocks.set_defaults(command="list-unicode-blocks")

    list_unicode_scripts = subcommand.add_parser(
        "list-unicode-scripts",
        help="List Unicode scripts",
    )
    list_unicode_scripts.set_defaults(command="list-unicode-scripts")

    inspect_font_coverage_by_blocks = subcommand.add_parser(
        "inspect-font-coverage-by-blocks",
        help="Inspect the coverage of the font by Unicode Blocks",
    )
    inspect_font_coverage_by_blocks.set_defaults(
        command="inspect-font-coverage-by-blocks"
    )
    inspect_font_coverage_by_blocks.add_argument(
        "fonts",
        help="The paths to the font files",
        nargs="+",
    )

    inspect_font_coverage_by_scripts = subcommand.add_parser(
        "inspect-font-coverage-by-scripts",
        help="Inspect the coverage of the font by Unicode Scripts",
    )
    inspect_font_coverage_by_scripts.set_defaults(
        command="inspect-font-coverage-by-scripts"
    )
    inspect_font_coverage_by_scripts.add_argument(
        "fonts",
        help="The paths to the font files",
        nargs="+",
    )

    patch_cjk_font = subcommand.add_parser(
        "patch-cjk-font",
        help=(
            "Enlarge a CJK font so that a full-width glyph is as wide as "
            "2 half-width glyphs of the reference font, "
            "copy the line height of the reference font, "
            "and mark the font as fixed-pitch"
        ),
    )
    patch_cjk_font.set_defaults(command="patch-cjk-font")
    patch_cjk_font.add_argument(
        "--reference",
        required=True,
        help="The path to the reference font, e.g. JetBrains Mono",
    )
    patch_cjk_font.add_argument(
        "--family-suffix",
        required=True,
        help="The suffix of the new family name, e.g. 'Jigmo' -> 'Jigmo RealMono'",
    )
    patch_cjk_font.add_argument("input", help="The path to the CJK font")
    patch_cjk_font.add_argument("output", help="The path to the patched font")

    args = parser.parse_args()
    match args.command:
        case "list-unicode-blocks":
            cmd_list_unicode_blocks(args)
        case "list-unicode-scripts":
            cmd_list_unicode_scripts(args)
        case "inspect-font-coverage-by-blocks":
            cmd_inspect_font_coverage_by_blocks(args)
        case "inspect-font-coverage-by-scripts":
            cmd_inspect_font_coverage_by_scripts(args)
        case "patch-cjk-font":
            cmd_patch_cjk_font(args)


main()
