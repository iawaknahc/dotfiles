#!/usr/bin/env python3
import argparse
from collections.abc import Sequence
from datetime import date, timedelta
from typing import cast

import beanquery
from beancount import Inventory


# This program roughly does what `hledger close --assert` does.
def main():
    parser = argparse.ArgumentParser(
        description="Print balance assertions for all Assets and Liabilities accounts."
    )
    _ = parser.add_argument("filename", help="Path to the Beancount file")
    args = parser.parse_args()

    today = date.today()
    tomorrow = today + timedelta(days=1)

    filename = cast(str, args.filename)
    conn = beanquery.connect(None)
    conn.attach(f"beancount:{filename}")

    accounts = [
        t[0]
        for t in cast(
            list[tuple[str]],
            conn.execute(
                "SELECT account FROM #accounts WHERE account ~ 'Assets:|Liabilities:' "
            ).fetchall(),
        )
    ]

    rows_of_account_and_inventories = cast(
        list[tuple[str, Sequence[Inventory]]],
        conn.execute("SELECT account, sum(position) FROM CLEAR").fetchall(),
    )

    # Find the longest width so that we can print the lines nicely.
    longest_account_len = 0
    longest_inventory_len = 0
    for account in accounts:
        for row in rows_of_account_and_inventories:
            if account == row[0]:
                inventories = row[1]
                if len(inventories) > 0:
                    if len(account) > longest_account_len:
                        longest_account_len = len(account)
                for inventory in inventories:
                    if len(str(inventory)) > longest_inventory_len:
                        longest_inventory_len = len(str(inventory))

    # We iterate from `accounts`, assuming that the source order of accounts is the expected order.
    for account in accounts:
        for row in rows_of_account_and_inventories:
            if account == row[0]:
                inventories = row[1]
                for inventory in inventories:
                    print(
                        f"{tomorrow.isoformat()} balance {account:<{longest_account_len}}  {str(inventory):>{longest_inventory_len}}"
                    )


main()
