#!/usr/bin/env python3
import argparse
import datetime
import subprocess
import sys
from pathlib import PurePath
from typing import NamedTuple, cast

import beanquery  # pyright: ignore[reportMissingTypeStubs]


class PriceHistory(NamedTuple):
    base: str
    quote: str
    min_date: datetime.date
    max_date: datetime.date


class PriceHistInvocation(NamedTuple):
    base: str
    quote: str
    source: str
    pair: str
    start_date: datetime.date
    end_date: datetime.date


class PriceHistConfig(NamedTuple):
    source: str
    pair: str
    quote: str


def parse_price_hist_config(s: str) -> list[PriceHistConfig]:
    out: list[PriceHistConfig] = []
    parts = s.split(",")
    for part in parts:
        cfg = part.split(" ")
        assert len(cfg) == 3
        source = cfg[0]
        pair = cfg[1]
        quote = cfg[2]
        out.append(PriceHistConfig(source=source, pair=pair, quote=quote))
    return out


def build_price_history(conn: beanquery.Connection) -> list[PriceHistory]:
    out: list[PriceHistory] = []
    prices = cast(
        list[tuple[str, str, datetime.date, datetime.date]],
        conn.execute(  # pyright: ignore[reportUnknownMemberType]
            "SELECT currency AS base, currency(amount) AS quote, min(date) AS min_date, max(date) AS max_date FROM #prices GROUP BY 1, 2"
        ).fetchall(),
    )
    for price_row in prices:
        base = price_row[0]
        quote = price_row[1]
        min_date = price_row[2]
        max_date = price_row[3]
        out.append(
            PriceHistory(base=base, quote=quote, min_date=min_date, max_date=max_date)
        )
    return out


def build_invocations(
    conn: beanquery.Connection,
    *,
    global_end_date: datetime.date,
    history: list[PriceHistory],
) -> list[PriceHistInvocation]:
    out: list[PriceHistInvocation] = []
    commodities = cast(
        list[tuple[datetime.date, str, str]],
        conn.execute(  # pyright: ignore[reportUnknownMemberType]
            "SELECT date, name AS base, meta['pricehist'] FROM #commodities WHERE 'pricehist' IN meta"
        ).fetchall(),
    )
    for row in commodities:
        currency_date = row[0]
        base = row[1]
        pricehist_config = parse_price_hist_config(row[2])
        for cfg in pricehist_config:
            quote = cfg.quote

            # Find the history
            found: PriceHistory | None = None
            for h in history:
                if h.base == base and h.quote == quote:
                    found = h
                    break

            if found is not None:
                # If history is found, then we should fetch the price after the max_date of the history
                start_date = found.max_date + datetime.timedelta(days=1)
            else:
                # Otherwise, we should fetch the price starting from when the currency was defined.
                start_date = currency_date

            if global_end_date < start_date:
                # The user requested an end date before the start date.
                # We should skip.
                continue
            elif found is not None and global_end_date <= found.max_date:
                # The user requested an end date within the history.
                # We assume we have fetched the prices already.
                # We should skip.
                continue

            end_date = global_end_date
            invocation = PriceHistInvocation(
                base=base,
                quote=quote,
                source=cfg.source,
                pair=cfg.pair,
                start_date=start_date,
                end_date=end_date,
            )
            out.append(invocation)
    return out


def main():
    parser = argparse.ArgumentParser(description="Fetch prices with pricehist")
    _ = parser.add_argument("filename", help="Path to the Beancount file")
    _ = parser.add_argument(
        "-o", "--output", help="Path to the output directory", default="./prices"
    )
    _ = parser.add_argument(
        "--end",
        help="The end date. The default is tomorrow",
        type=datetime.date.fromisoformat,
    )
    args = parser.parse_args()

    filename = cast(str, args.filename)
    output = cast(str, args.output)
    conn = beanquery.connect(None)  # pyright: ignore[reportUnknownMemberType]
    conn.attach(f"beancount:{filename}")  # pyright: ignore[reportUnknownMemberType]

    end_date_default = datetime.date.today() + datetime.timedelta(days=1)
    global_end_date = cast(datetime.date | None, args.end) or end_date_default

    history = build_price_history(conn)
    invocations = build_invocations(
        conn,
        global_end_date=global_end_date,
        history=history,
    )
    for invocation in invocations:
        command = [
            "pricehist",
            "fetch",
            invocation.source,
            invocation.pair,
            "--output",
            "beancount",
            "--fmt-base",
            invocation.base,
            "--fmt-quote",
            invocation.quote,
            "--start",
            invocation.start_date.isoformat(),
            "--end",
            invocation.end_date.isoformat(),
        ]
        print(" ".join(command), file=sys.stderr)
        _ = subprocess.run(
            command,
            shell=False,
            # Do not check because sometimes, there is no available source.
            check=False,
            stdout=open(PurePath(output) / f"{invocation.base}.beancount", "a"),
        )


main()
