#!/usr/bin/env python3

import csv
import sys

RANGES = [
    (0x3400, 0x4DBF),  # CJK Unified Ideographs Extension A
    (0xF900, 0xFAFF),  # CJK Compatibility Ideographs
    (0x20000, 0x2A6DF),  # CJK Unified Ideographs Extension B
    (0x2A700, 0x2B73F),  # CJK Unified Ideographs Extension C
    (0x2B740, 0x2B81F),  # CJK Unified Ideographs Extension D
    (0x2B820, 0x2CEAF),  # CJK Unified Ideographs Extension E
    (0x2CEB0, 0x2EBEF),  # CJK Unified Ideographs Extension F
    (0x2F800, 0x2FA1F),  # CJK Compatibility Ideographs Supplement
    (0x30000, 0x3134F),  # CJK Unified Ideographs Extension G
    (0x31350, 0x323AF),  # CJK Unified Ideographs Extension H
    (0x2EBF0, 0x2EE5F),  # CJK Unified Ideographs Extension I
    (0x323B0, 0x3347F),  # CJK Unified Ideographs Extension J
]


def is_in_unicode_cjk_extension_block(character: int) -> bool:
    for r in RANGES:
        lower = r[0]
        upper = r[1]
        if character >= lower and character <= upper:
            return True

    return False


# This program converts the CSV https://words.hk/faiman/analysis/charcount.csv
# into a Lua script that, when imported, returns a table containing
# characters that are in Unicode CJK extension blocks, but are common in Hong Kong.
# The primary use case is to build a custom filter that drops
# characters in Unicode CJK extension blocks, but keep those that are common in
# Hong Kong.
def main():
    reader = csv.reader(sys.stdin)
    targets: list[str] = []
    for row in reader:
        # We treat the presence in the CSV as being common.
        # The weight is not considered.
        character = row[0]
        # The CSV may contain non-CJK characters, such as emojis.
        # Just ignore them.
        if len(character) > 1:
            continue
        character = ord(character[0])
        if is_in_unicode_cjk_extension_block(character):
            targets.append(chr(character))
    print("local M = {}")
    print()
    print("M.common_in_hong_kong = {")
    for target in targets:
        print(f'  "{target}",')
    print("}")
    print()
    print("M.unicode_cjk_extension_ranges = {")
    for r in RANGES:
        print("  { " + str(r[0]) + ", " + str(r[1]) + " },")
    print("}")
    print()
    print("return M")


main()
