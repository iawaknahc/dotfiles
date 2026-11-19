"""
Convert GL-MahjongTile-Clr from WOFF to OpenType, and patch it to match JetBrains Mono NL:
1. The rotated tiles are dropped. Only the upright tiles are kept.
2. An upright tile is as wide as 2 glyphs of the reference font.
3. The line height is the same as the reference font.
4. A tile is drawn within the line, slightly smaller than the line height,
   so it does not overflow into the lines above and below.
5. The font is monospace: a space is 1 column wide, and every other glyph is 2 columns wide.
6. The family is renamed to "GL-MahjongTile-Clr FullWidth".

The font is enlarged by lowering head.unitsPerEm, so that the advance width of a tile does not have to change.
This also enlarges the SVG glyphs, because SVG glyphs are drawn in font units.
A tile is then taller than the line, so the SVG glyph of every tile is shrunk to fit the line.
"""

import argparse
import collections
import fractions
import math
import re

from fontTools import subset
from fontTools.pens.boundsPen import BoundsPen
from fontTools.svgLib import SVGPath
from fontTools.ttLib import TTFont
from fontTools.ttLib.tables.S_V_G_ import SVGDocument

OLD_FAMILY = "GL-MahjongTile-Clr"
NEW_FAMILY = "GL-MahjongTile-Clr FullWidth"
# PostScript names cannot contain spaces.
OLD_POSTSCRIPT = "GL-MahjongTile-Clr"
NEW_POSTSCRIPT = "GL-MahjongTile-ClrFullWidth"

# The Unicode Mahjong Tiles that are assigned, U+1F000..U+1F02B.
UNICODE_TILES = range(0x1F000, 0x1F02C)

# The height of a tile, as a fraction of the line height.
# A tile slightly smaller than the line leaves a gap between tiles on adjacent lines.
TILE_HEIGHT_RATIO = fractions.Fraction(9, 10)

# The range of head.unitsPerEm allowed by the OpenType spec.
MIN_UNITS_PER_EM = 16
MAX_UNITS_PER_EM = 16384

# Every SVG document in the font is a single <svg> element without a viewBox.
SVG_ROOT = re.compile(r"(?P<open><svg\b[^>]*>)(?P<body>.*)</svg>", re.DOTALL)

GLYPH_TRANSFORM = re.compile(
    r'<g transform="translate\((?P<tx>[^,]+),(?P<ty>[^)]+)\) scale\((?P<k>[^)]+)\)">'
)

# The glyphs whose SVG documents draw nothing.
BLANK_GLYPHS = {"space", "uni3000"}

NAME_ID_FAMILY = 1
NAME_ID_UNIQUE = 3
NAME_ID_FULL = 4
NAME_ID_POSTSCRIPT = 6


Bounds = tuple[float, float, float, float]


def svg_bounds_or_none(data: str, transform=None) -> Bounds | None:
    """
    The bounds of an SVG glyph, in SVG coordinates (y points down), or None if it draws nothing.
    SVGPath ignores the transform attribute of <g>, so TRANSFORM has to be given explicitly.
    """
    pen = BoundsPen(None)
    SVGPath.fromstring(data.encode(), transform=transform).draw(pen)
    return pen.bounds


def svg_bounds(data: str, transform=None) -> Bounds:
    """Like svg_bounds_or_none, but the SVG glyph must draw something."""
    bounds = svg_bounds_or_none(data, transform)
    if bounds is None:
        raise ValueError(f"the SVG glyph draws nothing: {data[:80]!r}")
    return bounds


def best_cmap(font: TTFont) -> dict[int, str]:
    cmap = font.getBestCmap()
    if cmap is None:
        raise ValueError("no Unicode cmap")
    return cmap


def svg_documents(font: TTFont) -> dict[str, SVGDocument]:
    """A dict from glyph names to SVG documents, for the glyphs that draw something."""
    glyph_order = font.getGlyphOrder()
    documents: dict[str, SVGDocument] = {}
    for document in font["SVG "].docList:
        if document.startGlyphID != document.endGlyphID:
            raise ValueError(
                f"SVG document for glyphs {document.startGlyphID}..{document.endGlyphID}: "
                "expected one glyph per document"
            )
        documents[glyph_order[document.startGlyphID]] = document
    if set(documents) != set(glyph_order):
        raise ValueError(
            f"glyphs without an SVG document: {sorted(set(glyph_order) - set(documents))}"
        )
    blank = {
        name
        for name, document in documents.items()
        if svg_bounds_or_none(document.data) is None
    }
    if blank != BLANK_GLYPHS:
        raise ValueError(
            f"expected exactly {sorted(BLANK_GLYPHS)} to draw nothing, got {sorted(blank)}"
        )
    return {
        name: document
        for name, document in documents.items()
        if name not in BLANK_GLYPHS
    }


def drop_rotated_tiles(font: TTFont):
    """
    drop_rotated_tiles removes the rotated tiles, which are drawn wider than they are tall.
    They are typed with Shift in the keyboard mapping of the font, and have no Unicode codepoint of their own.
    """
    rotated = set()
    for name, document in svg_documents(font).items():
        x_min, y_min, x_max, y_max = svg_bounds(document.data)
        if x_max - x_min > y_max - y_min:
            rotated.add(name)
    if not rotated:
        raise ValueError("expected some rotated tiles")
    old_cmap = best_cmap(font)

    options = subset.Options(
        # Do not add glyphs back through GSUB. Lookups that refer to dropped glyphs are pruned instead.
        layout_closure=False,
        layout_features=["*"],
        name_IDs=["*"],
        name_languages=["*"],
        name_legacy=True,
        legacy_cmap=True,
        notdef_glyph=True,
        notdef_outline=True,
        glyph_names=True,
        hinting=True,
        recalc_bounds=False,
        recalc_timestamp=False,
    )
    subsetter = subset.Subsetter(options)
    subsetter.populate(
        glyphs=[name for name in font.getGlyphOrder() if name not in rotated]
    )
    subsetter.subset(font)

    remaining = set(font.getGlyphOrder()) & rotated
    if remaining:
        raise ValueError(f"rotated tiles remain after subsetting: {sorted(remaining)}")
    expected_cmap = {
        codepoint: name for codepoint, name in old_cmap.items() if name not in rotated
    }
    if best_cmap(font) != expected_cmap:
        raise ValueError(
            "the cmap after subsetting is not the old cmap without the rotated tiles"
        )
    print(
        f"dropped {len(rotated)} rotated tiles, {len(font.getGlyphOrder())} glyphs remain"
    )


def read_reference(path: str):
    font = TTFont(path)
    upm = font["head"].unitsPerEm  # ty: ignore[unresolved-attribute]
    cmap = best_cmap(font)
    hhea = font["hhea"]
    half_width = fractions.Fraction(font["hmtx"][cmap[0x20]][0], upm)
    ascender = fractions.Fraction(hhea.ascent, upm)
    descender = fractions.Fraction(-hhea.descent, upm)
    line_gap = fractions.Fraction(hhea.lineGap, upm)  # ty: ignore[unresolved-attribute]
    return half_width, ascender, descender, line_gap


def scale(font: TTFont, reference: str):
    """
    scale enlarges the font so that a Unicode tile is as wide as 2 glyphs of REFERENCE,
    and copies the line height of REFERENCE.
    """
    half_width, ascender, descender, line_gap = read_reference(reference)

    cmap = best_cmap(font)
    hmtx = font["hmtx"]
    widths = {hmtx[cmap[codepoint]][0] for codepoint in UNICODE_TILES}
    if len(widths) != 1:
        raise ValueError(
            f"expected all Unicode tiles to have the same width, got {sorted(widths)}"
        )
    (tile_width,) = widths

    upm = font["head"].unitsPerEm  # ty: ignore[unresolved-attribute]
    new_upm = round(tile_width / (2 * half_width))
    if not (MIN_UNITS_PER_EM <= new_upm <= MAX_UNITS_PER_EM):
        raise ValueError(f"the new units per em {new_upm} is out of range")
    if (
        tile_width % 2 != 0
        or fractions.Fraction(tile_width // 2, new_upm) != half_width
    ):
        raise ValueError(
            f"a tile ({tile_width} units) is not exactly 2 columns of the reference font "
            f"with {new_upm} units per em"
        )
    font["head"].unitsPerEm = new_upm  # ty: ignore[unresolved-attribute]
    # Keep the CFF FontMatrix consistent with head.unitsPerEm.
    font["CFF "].cff.topDictIndex[0].FontMatrix = [1 / new_upm, 0, 0, 1 / new_upm, 0, 0]

    # Round down, so that this font never makes a line taller than the reference font does.
    new_ascender = math.floor(ascender * new_upm)
    new_descender = math.floor(descender * new_upm)
    new_line_gap = math.floor(line_gap * new_upm)
    hhea = font["hhea"]
    hhea.ascent = new_ascender
    hhea.descent = -new_descender
    hhea.lineGap = new_line_gap  # ty: ignore[unresolved-attribute]
    os2 = font["OS/2"]
    os2.sTypoAscender = new_ascender  # ty: ignore[unresolved-attribute]
    os2.sTypoDescender = -new_descender  # ty: ignore[unresolved-attribute]
    os2.sTypoLineGap = new_line_gap  # ty: ignore[unresolved-attribute]
    os2.usWinAscent = new_ascender  # ty: ignore[unresolved-attribute]
    os2.usWinDescent = new_descender  # ty: ignore[unresolved-attribute]

    print(
        f"unitsPerEm {upm} -> {new_upm}, "
        f"so a Unicode tile is {float(fractions.Fraction(tile_width, new_upm)):.4f}em wide"
    )
    print(f"ascender={new_ascender} descender={new_descender} lineGap={new_line_gap}")


def make_monospace(font: TTFont):
    """
    make_monospace makes a space 1 column wide and every other glyph 2 columns wide,
    where a Unicode tile is 2 columns wide.
    It then marks the font as monospace.
    """
    cmap = best_cmap(font)
    hmtx = font["hmtx"]
    (tile_width,) = {hmtx[cmap[codepoint]][0] for codepoint in UNICODE_TILES}
    column = tile_width // 2

    old_widths = collections.Counter()
    for name in font.getGlyphOrder():
        width, lsb = hmtx[name]
        old_widths[width] += 1
        hmtx[name] = (column if name == "space" else 2 * column, lsb)
    font["OS/2"].xAvgCharWidth = round(
        sum(width for width, _ in hmtx.metrics.values()) / len(hmtx.metrics)
    )

    # CoreText reports the font as monospace only with the flag in the CFF table.
    # The flag in the post table is set too, for other font engines.
    font["CFF "].cff.topDictIndex[0].isFixedPitch = 1
    font["post"].isFixedPitch = 1  # ty: ignore[unresolved-attribute]

    print(
        f"advance widths {dict(sorted(old_widths.items()))} -> space {column}, others {2 * column}"
    )


def fit_glyphs(font: TTFont):
    """
    fit_glyphs shrinks the SVG glyphs so that they fit in the line.

    Every glyph is scaled by the same factor, so that a tile is TILE_HEIGHT_RATIO of the line height.
    Each glyph is then centered horizontally in its advance width, and vertically in the line.
    """
    hmtx = font["hmtx"]
    ascender = font["hhea"].ascent
    descender = -font["hhea"].descent
    documents = svg_documents(font)
    bounds = {name: svg_bounds(document.data) for name, document in documents.items()}

    tile_sizes = {
        (x_max - x_min, y_max - y_min)
        for name, (x_min, y_min, x_max, y_max) in bounds.items()
        if name != ".notdef"
    }
    if len(tile_sizes) != 1:
        raise ValueError(
            f"expected all tiles to have the same size, got {sorted(tile_sizes)}"
        )
    ((_, tile_height),) = tile_sizes
    factor = float(
        TILE_HEIGHT_RATIO * (ascender + descender) / fractions.Fraction(tile_height)
    )

    for name, document in documents.items():
        x_min, y_min, x_max, y_max = bounds[name]
        advance = hmtx[name][0]
        # In SVG glyphs, y points down, so the top of the line is -ascender and the bottom is descender.
        translate_x = (advance - (x_max - x_min) * factor) / 2 - x_min * factor
        translate_y = (
            descender - ascender - (y_max - y_min) * factor
        ) / 2 - y_min * factor
        transform = f"translate({translate_x!r},{translate_y!r}) scale({factor!r})"
        match = SVG_ROOT.fullmatch(document.data.strip())
        if match is None:
            raise ValueError(f"{name}: unexpected SVG document: {document.data[:80]!r}")
        document.data = (
            f'{match["open"]}<g transform="{transform}">{match["body"]}</g></svg>'
        )

    # Check the result, so that no glyph is drawn outside the line or outside its advance width.
    # The transform is read back from the written SVG, so that the check covers its formatting.
    tolerance = 1e-6
    for name, document in documents.items():
        match = GLYPH_TRANSFORM.search(document.data)
        if match is None:
            raise ValueError(f"{name}: the transform was not written")
        tx, ty, k = (float(match[key]) for key in ("tx", "ty", "k"))
        x0, y0, x1, y1 = svg_bounds(document.data, transform=(k, 0, 0, k, tx, ty))
        advance = hmtx[name][0]
        if (
            x0 < -tolerance
            or x1 > advance + tolerance
            or y0 < -ascender - tolerance
            or y1 > descender + tolerance
        ):
            raise ValueError(f"{name} is drawn outside the line: {(x0, y0, x1, y1)}")

    print(f"scaled {len(documents)} SVG glyphs by {factor!r}")


def rename(font: TTFont):
    expected = {
        NAME_ID_FAMILY: OLD_FAMILY,
        NAME_ID_FULL: f"{OLD_FAMILY} Regular",
        NAME_ID_POSTSCRIPT: OLD_POSTSCRIPT,
    }
    for record in font["name"].names:
        old = record.toUnicode()
        if record.nameID in expected:
            if old != expected[record.nameID]:
                raise ValueError(
                    f"name ID {record.nameID}: expected {expected[record.nameID]!r}, got {old!r}"
                )
            if record.nameID == NAME_ID_POSTSCRIPT:
                record.string = NEW_POSTSCRIPT
            else:
                record.string = old.replace(OLD_FAMILY, NEW_FAMILY, 1)
        elif record.nameID == NAME_ID_UNIQUE:
            if not old.endswith(f";{OLD_POSTSCRIPT}"):
                raise ValueError(
                    f"name ID {NAME_ID_UNIQUE}: unexpected unique ID {old!r}"
                )
            record.string = old.removesuffix(OLD_POSTSCRIPT) + NEW_POSTSCRIPT

    # The CFF table has its own copy of the PostScript name and the full name.
    cff = font["CFF "].cff
    if cff.fontNames != [OLD_POSTSCRIPT]:
        raise ValueError(f"CFF: unexpected font names {cff.fontNames!r}")
    cff.fontNames = [NEW_POSTSCRIPT]
    top_dict = cff.topDictIndex[0]
    top_dict.FullName = f"{NEW_FAMILY} Regular"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--reference", required=True, help="the font to match, e.g. JetBrains Mono NL"
    )
    parser.add_argument("input", help="GL-MahjongTile-Clr.woff")
    parser.add_argument("output", help="the OpenType font to write")
    args = parser.parse_args()

    # recalcBBoxes=False and recalcTimestamp=False keep head and maxp as they are,
    # apart from the fields changed below.
    font = TTFont(args.input, recalcBBoxes=False, recalcTimestamp=False)
    if font.flavor != "woff":
        raise ValueError(f"expected a WOFF font, got flavor {font.flavor!r}")
    # WOFF is a compressed wrapper around an OpenType font.
    # Removing the wrapper gives back the original OpenType font.
    font.flavor = None

    drop_rotated_tiles(font)
    scale(font, args.reference)
    make_monospace(font)
    fit_glyphs(font)
    rename(font)
    font.save(args.output)
    print(f"wrote {args.output}")


if __name__ == "__main__":
    main()
