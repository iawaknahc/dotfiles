#!/usr/bin/env python3

import argparse
import copy
import io
from decimal import Decimal
from typing import Callable, cast

from autobean_refactor import models, parser, printer

ZERO = Decimal("0")

Subcommand = Callable[[argparse.Namespace], None]


def cmd_simplify(args: argparse.Namespace):
    filepath = cast(str, args.filepath)
    with open(filepath, "r") as f:
        text = f.read()

    p = parser.Parser()
    file = p.parse(text, models.File)
    for directive in file.directives:
        if isinstance(directive, models.Transaction):
            if len(directive.postings) == 2:
                first_posting = cast(models.Posting, directive.postings[0])
                second_posting = cast(models.Posting, directive.postings[1])
                if (
                    first_posting.cost is None
                    and second_posting.cost is None
                    and first_posting.price is None
                    and second_posting.price is None
                ):
                    assert first_posting.number is not None
                    if first_posting.number == ZERO:
                        continue

                    if first_posting.number < ZERO:
                        first_posting, second_posting = (
                            copy.deepcopy(second_posting),
                            copy.deepcopy(first_posting),
                        )
                        directive.postings[0] = first_posting
                        directive.postings[1] = second_posting

                    new_second_posting = copy.deepcopy(second_posting)
                    new_second_posting.number = None
                    new_second_posting.currency = None
                    directive.postings[1] = new_second_posting

    print(printer.print_model(file, io.StringIO()).getvalue())


def main():
    ap = argparse.ArgumentParser(description="Refactor Beancount files")
    sub = ap.add_subparsers(dest="subcommand", required=True)

    p_fill = sub.add_parser(
        "simplify",
        help="Simplify the postings of simple transactions",
    )
    _ = p_fill.add_argument("filepath", help="Beancount file to process")
    p_fill.set_defaults(func=cmd_simplify)

    args = ap.parse_args()
    cast(Subcommand, args.func)(args)


if __name__ == "__main__":
    main()
