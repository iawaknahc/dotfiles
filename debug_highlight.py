import sys
from dataclasses import dataclass
from typing import Optional


@dataclass
class HighlightGroup:
    line: str
    name: str
    cleared: bool
    links_to: Optional[str]
    attributes: dict[str, str]

    def __init__(self, *, line: str, name: str, cleared: bool = False, links_to: Optional[str] = None, attributes: Optional[dict[str, str]] = None):
        self.line = line
        self.name = name
        self.cleared = cleared
        self.links_to = links_to
        if attributes is None:
            self.attributes = {}
        else:
            self.attributes = attributes


def read_lines(f) -> list[str]:
    lines = []
    last_line = None
    for line in f:
        # Remove the newline at the end
        line = line.rstrip("\n")

        # Skip empty lines.
        if line == "":
            continue

        if line.startswith(" "):
            # If the line start with spaces, then it is a continuation of the last line.
            line = line.lstrip(" ")
            assert last_line is not None
            last_line = last_line + " " + line
        else:
            # Otherwise we encounter a separate line, the last line is complete.
            if last_line is not None:
                lines.append(last_line)
            last_line = line

    # When the loop is over, we may have a last line.
    if last_line is not None:
        lines.append(last_line)
        last_line = None

    return lines


def parse_line(line) -> HighlightGroup:
    parts = [part for part in line.split(" ") if part != ""]

    if len(parts) < 2:
        raise ValueError(f"unexpected line: {line}")

    name = parts[0]
    xxx = parts[1]
    if xxx != "xxx":
        raise ValueError(f"unexpected line: {line}")
    cleared = False
    links_to = None
    attributes = {}

    remaining = parts[2:]
    for idx, val in enumerate(remaining):
        if val == "cleared":
            cleared = True
        if val == "links":
            links_to = remaining[idx + 2]
        if "=" in val:
            attr_key, attr_val = val.split("=")
            attributes[attr_key] = attr_val

    return HighlightGroup(line=line, name=name, cleared=cleared, links_to=links_to, attributes=attributes)


# This program takes the output of my fish abbreviation nvim-highlight, and
# prints out any highlight group that are not linked to Dracula yet.
def main():
    lines = read_lines(sys.stdin)

    highlight_groups = []
    name_to_highlight_group = {}

    for line in lines:
        hg = parse_line(line)
        highlight_groups.append(hg)
        name_to_highlight_group[hg.name] = hg

    for hg in highlight_groups:
        # We want to find the groups where
        #   They are not Nvim* nor Dracula*, AND
        #   They are not cleared AND
        #   They link to Nvim*, OR
        #   They do not link.

        if hg.name.startswith("Dracula") or hg.name.startswith("Nvim"):
            continue

        if hg.cleared:
            continue

        if hg.links_to is not None:
            try:
                dest = name_to_highlight_group[hg.links_to]
                if dest.name.startswith("Nvim"):
                    print(dest.line)
            except KeyError:
                print(f"{hg.name} links to non-existent {hg.links_to}")

        if hg.links_to is None:
            print(hg.line)


if __name__ == "__main__":
    main()
