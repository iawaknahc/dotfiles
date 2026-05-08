#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import date
from typing import Literal, cast

from dateutil.relativedelta import relativedelta


# ArgumentDefaultsHelpFormatter prints default=None even I did not specify it.
# default=argparse.SUPPRESS suppresses this behavior.
# The side effect of default=argparse.SUPPRESS is that if the option is unspecified,
# then the attribute is not present.
# This implies we need to use hasattr to check if the flag was specified.
class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def nonzero(s: str) -> int:
    v = int(s)
    if v == 0:
        raise ValueError("must be non-zero")
    return v


def main():
    parser = argparse.ArgumentParser(
        description="Generate DATE series",
        formatter_class=Formatter,
    )

    _ = parser.add_argument(
        "--increment",
        help="The amount to increment",
        type=nonzero,
        default=1,
    )

    _ = parser.add_argument(
        "--unit",
        help="The unit to increment",
        choices=["year", "month", "day"],
        default="day",
    )

    _ = parser.add_argument(
        "--start",
        help="The start of the series in YYYY-MM-dd",
        type=date.fromisoformat,
    )

    _ = parser.add_argument(
        "--end",
        help="The inclusive end of the series in YYYY-MM-dd",
        type=date.fromisoformat,
    )

    args = parser.parse_args()
    increment = cast(int, args.increment)
    unit = cast(Literal["year", "month", "day"], args.unit)
    start = cast(date | None, args.start)
    end = cast(date | None, args.end)
    if start is None:
        start = date.today()
    if end is None:
        end = start

    d = start
    while True:
        print(f"=DATE({d.year}, {d.month}, {d.day})")
        if unit == "year":
            d += relativedelta(years=increment)
        elif unit == "month":
            d += relativedelta(months=increment)
        elif unit == "day":
            d += relativedelta(days=increment)
        if increment > 0 and d > end:
            break
        if increment < 0 and d < end:
            break


if __name__ == "__main__":
    main()
