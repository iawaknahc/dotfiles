#!/usr/bin/env python3
import json
import sys
from decimal import Decimal
from typing import TypedDict, cast

import pyxirr


class Input(TypedDict):
    dates: list[str]
    amounts: list[str]


def main():
    o = cast(Input, json.load(sys.stdin))
    dates = o["dates"]
    amounts = [Decimal(s) for s in o["amounts"]]
    result = pyxirr.xirr(dates, amounts)
    if result is None:
        sys.exit(1)
    print(Decimal(result))


if __name__ == "__main__":
    main()
