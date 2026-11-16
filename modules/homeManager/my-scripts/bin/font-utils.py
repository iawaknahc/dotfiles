#!/usr/bin/env python3
import argparse
import dataclasses
import io
import pathlib
from typing import Self

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

    def intersect(self, that: Self) -> int:
        return max(0, min(self.end, that.end) - max(self.start, that.start) + 1)


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
class UnicodeScriptStatistics:
    range: UnicodeRange
    total: int


@dataclasses.dataclass
class UnicodeScript:
    script_name: str
    ranges: list[UnicodeScriptStatistics]

    def __str__(self) -> str:
        buf = io.StringIO()
        print(f"{self.script_name}", file=buf)
        for range in self.ranges:
            print(
                f"  {range.range.start:04X}..{range.range.end:04X} {range.range.size}/{range.total} {range.range.size / range.total * 100:.0f}%",
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
            intersection = block.range.intersect(pair[0])
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


def cmd_list_unicode_scripts(args: argparse.Namespace):
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
                ranges=[
                    UnicodeScriptStatistics(range=unicode_range, total=total)
                    for unicode_range in ranges
                ],
            )
        )
    scripts = sorted(scripts, key=lambda script: script.script_name)

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


def cmd_inspect_font_coverage(args: argparse.Namespace):
    path_to_font = pathlib.Path(args.font).expanduser()

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
    for table in cmap.tables:
        # platformID 3 means Windows
        # platEncID 10 means Unicode full repertoire
        # format 12 is a must when platformID == 3 and platEncID == 10.
        # See https://learn.microsoft.com/en-us/typography/opentype/spec/cmap#windows-platform-platform-id--3
        if table.platformID == 3 and table.platEncID == 10 and table.format == 12:
            target = table
    if target is None:
        raise TypeError(
            f"cmap platformID==3 platEncID==10 format==12 not found: {path_to_font}"
        )
    codepoint_to_name: dict[int, str] = target.cmap
    codepoints = list(codepoint_to_name.keys())
    codepoints = sorted(codepoints, key=lambda codepoint: codepoint)
    ranges = codepoints_to_unicode_ranges(codepoints)

    total = 0
    for range in ranges:
        total += range.size

    block_coverages: list[tuple[UnicodeBlock, int]] = []
    blocks = prepare_unicode_blocks(args)
    for block in blocks:
        count = 0
        for range in ranges:
            count += block.range.intersect(range)
        block_coverages.append((block, count))

    print(font["name"].getBestFullName())
    for coverage in block_coverages:
        if coverage[1] > 0:
            print(
                f"{coverage[0].block_name} ({coverage[0].range.start:04X}..{coverage[0].range.end:04X}) {coverage[1]}/{coverage[0].size()} {coverage[1] / coverage[0].size() * 100:.0f}%"
            )


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

    inspect_font_coverage = subcommand.add_parser(
        "inspect-font-coverage",
        help="Inspect the coverage of the font",
    )
    inspect_font_coverage.set_defaults(command="inspect-font-coverage")
    inspect_font_coverage.add_argument(
        "font",
        help="The path to the font file",
    )

    args = parser.parse_args()
    match args.command:
        case "list-unicode-blocks":
            cmd_list_unicode_blocks(args)
        case "list-unicode-scripts":
            cmd_list_unicode_scripts(args)
        case "inspect-font-coverage":
            cmd_inspect_font_coverage(args)


main()
