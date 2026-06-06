#!/usr/bin/env python3

import argparse
import io
from typing import Callable, cast

from autobean_refactor import models, parser, printer

Subcommand = Callable[[argparse.Namespace], None]


def cmd_fill_2_posting(args: argparse.Namespace):
    filepath = cast(str, args.filepath)
    with open(filepath, "r") as f:
        text = f.read()

    p = parser.Parser()
    file = p.parse(text, models.File)
    for directive in file.directives:
        if isinstance(directive, models.Transaction):
            if len(directive.postings) == 2:
                number = None
                currency = None
                num_omitted = 0
                for posting in directive.postings:
                    if isinstance(posting, models.Posting):
                        if posting.number is None and posting.currency is None:
                            num_omitted += 1
                        elif (
                            posting.number is not None and posting.currency is not None
                        ):
                            number = posting.number
                            currency = posting.currency
                if num_omitted == 1 and number is not None and currency is not None:
                    for posting in directive.postings:
                        if isinstance(posting, models.Posting):
                            if posting.number is None and posting.currency is None:
                                posting.number = -number
                                posting.currency = currency

    print(printer.print_model(file, io.StringIO()).getvalue())


def main():
    ap = argparse.ArgumentParser(description="Refactor Beancount files")
    sub = ap.add_subparsers(dest="subcommand", required=True)

    p_fill = sub.add_parser(
        "fill-2-posting",
        help="Fill omitted posting amounts in simple 2-posting transactions",
    )
    _ = p_fill.add_argument("filepath", help="Beancount file to process")
    p_fill.set_defaults(func=cmd_fill_2_posting)

    args = ap.parse_args()
    cast(Subcommand, args.func)(args)


if __name__ == "__main__":
    main()
