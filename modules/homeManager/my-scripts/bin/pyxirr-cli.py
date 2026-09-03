#!/usr/bin/env python3
import argparse
import json
import sys
from decimal import Decimal
from typing import TypedDict, cast

import pyxirr


class XirrInput(TypedDict):
    dates: list[str]
    amounts: list[str]


class XnpvInput(TypedDict):
    rate: str
    dates: list[str]
    amounts: list[str]


def cmd_xirr():
    o = cast(XirrInput, json.load(sys.stdin))
    dates = o["dates"]
    amounts = [Decimal(s) for s in o["amounts"]]
    result = pyxirr.xirr(dates, amounts)
    if result is None:
        sys.exit(1)
    print(Decimal(result))


def cmd_xnpv():
    o = cast(XnpvInput, json.load(sys.stdin))
    rate = Decimal(o["rate"])
    dates = o["dates"]
    amounts = [Decimal(s) for s in o["amounts"]]
    result = pyxirr.xnpv(rate, dates, amounts)
    if result is None:
        sys.exit(1)
    print(Decimal(result))


def main():
    parser = argparse.ArgumentParser()
    subcommand = parser.add_subparsers(dest="command", required=True)
    _ = subcommand.add_parser(
        "xirr", help="Compute XIRR from dates and amounts read as JSON from stdin"
    )
    _ = subcommand.add_parser(
        "xnpv",
        help="Compute XNPV from a rate, dates, and amounts read as JSON from stdin",
    )
    args = parser.parse_args()

    match args.command:
        case "xirr":
            cmd_xirr()
        case "xnpv":
            cmd_xnpv()


if __name__ == "__main__":
    main()
