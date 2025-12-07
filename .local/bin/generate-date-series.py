#!/usr/bin/env python3

import argparse
from datetime import date
from typing import Literal

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

    parser.add_argument(
        "--increment",
        help="The amount to increment",
        type=nonzero,
        default=1,
    )

    parser.add_argument(
        "--unit",
        help="The unit to increment",
        choices=["year", "month", "day"],
        default="day",
    )

    parser.add_argument(
        "--start",
        help="The start of the series in YYYY-MM-dd",
        type=date.fromisoformat,
    )

    parser.add_argument(
        "--end",
        help="The inclusive end of the series in YYYY-MM-dd",
        type=date.fromisoformat,
    )

    args = parser.parse_args()
    increment: int = args.increment
    unit: Literal["year", "month", "day"] = args.unit
    start: date | None = args.start
    end: date | None = args.end
    if start is None:
        start = date.today()
    if end is None:
        end = start

    d = start
    while True:
        print(f"=DATE({d.year}, {d.month}, {d.day})")
        kwargs = {}
        if unit == "year":
            kwargs["years"] = increment
        elif unit == "month":
            kwargs["months"] = increment
        elif unit == "day":
            kwargs["days"] = increment
        d += relativedelta(**kwargs)
        if increment > 0 and d > end:
            break
        if increment < 0 and d < end:
            break


if __name__ == "__main__":
    main()
