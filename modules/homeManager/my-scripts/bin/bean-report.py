#!/usr/bin/env python3
import argparse
import datetime
from dataclasses import dataclass
from typing import Any, Callable, Literal, cast, override

import beanquery  # pyright: ignore[reportMissingTypeStubs]
import tabulate
from beancount.core.inventory import Inventory
from beancount.core.position import Cost, Position
from beanquery import query_env  # pyright: ignore[reportMissingTypeStubs]
from my_plugins.currencies import (  # pyright: ignore[reportMissingTypeStubs]
    get_decimal_places,
)

Period = (
    Literal["daily"]
    | Literal["weekly"]
    | Literal["monthly"]
    | Literal["quarterly"]
    | Literal["yearly"]
    | Literal["hong-kong"]
)

AssetClass = (
    Literal["cash"]
    | Literal["stock"]
    | Literal["fixed-income"]
    | Literal["derivative"]
    | Literal["retirement-fund"]
    | Literal["cryptocurrency"]
    | Literal["property"]
    | Literal["vehicle"]
)


def parse_asset_class(s: str) -> AssetClass:
    match s:
        case (
            "cash"
            | "stock"
            | "fixed-income"
            | "derivative"
            | "retirement-fund"
            | "cryptocurrency"
            | "property"
            | "vehicle"
        ):
            return cast(AssetClass, s)  # pyright: ignore[reportUnnecessaryCast]
        case _:
            raise ValueError()


def date_to_period_group_key(period: Period, d: datetime.date) -> str:
    match period:
        case "daily":
            return d.isoformat()
        case "weekly":
            return d.strftime("%G-W%V")
        case "monthly":
            return d.strftime("%Y-%m")
        case "quarterly":
            match d.month:
                case 1 | 2 | 3:
                    return d.strftime("%Y-Q1")
                case 4 | 5 | 6:
                    return d.strftime("%Y-Q2")
                case 7 | 8 | 9:
                    return d.strftime("%Y-Q3")
                case 10 | 11 | 12:
                    return d.strftime("%Y-Q4")
                case _:
                    raise ValueError("unreachable")
        case "yearly":
            return d.strftime("%Y")
        case "hong-kong":
            if d.month < 4:
                start = datetime.date(year=d.year - 1, month=4, day=1)
                end = datetime.date(year=d.year, month=3, day=31)
                return f"{start} to {end}"
            else:
                start = datetime.date(year=d.year, month=4, day=1)
                end = datetime.date(year=d.year + 1, month=3, day=31)
                return f"{start} to {end}"


@dataclass
class Range:
    period: Period
    start: datetime.date
    end: datetime.date

    @override
    def __str__(self):
        return date_to_period_group_key(self.period, self.start)


@dataclass(order=True, unsafe_hash=True)
class AccountLot:
    account: str
    commodity: str
    cost: Cost | None

    @override
    def __str__(self) -> str:
        return f"{self.account}"


@dataclass
class DataPoint:
    account: str
    position: Position
    range: Range
    account_lot: AccountLot

    def __init__(self, *, account: str, position: Position, range: Range):
        self.account = account
        self.position = position
        self.range = range
        self.account_lot = AccountLot(
            account=account,
            commodity=position.units.currency,
            cost=position.cost,
        )


@dataclass
class Input:
    period: Period
    start: datetime.date
    end: datetime.date
    conn: beanquery.Connection
    account_level: int | None
    asset_class: list[AssetClass] | None
    where_clause: str | None
    ranges: list[Range]

    def __init__(
        self,
        *,
        period: Period,
        start: datetime.date,
        end: datetime.date,
        conn: beanquery.Connection,
        account_level: int | None,
        asset_class: list[AssetClass] | None,
        where_clause: str | None,
    ):
        self.period = period
        self.start = start
        self.end = end
        self.conn = conn
        self.account_level = account_level
        self.ranges = get_ranges(period=period, start=start, end=end)
        self.asset_class = asset_class
        self.where_clause = where_clause


Subcommand = Callable[[Input], None]


def account_level_to_column(account_level: int | None) -> str:
    if account_level is None:
        return "account"
    return f"root(account, {account_level})"


@query_env.function([str, datetime.date], str)  # pyright: ignore[reportUnknownMemberType]
def x_date_to_period_group_key(period: Period, d: datetime.date) -> str:
    return date_to_period_group_key(period, d)


def cmd_income_statement(input: Input):
    where_clause = input.where_clause if input.where_clause is not None else "TRUE"

    account_column = account_level_to_column(input.account_level)
    account_columns = [
        account_column,  # The user-specified account column
        "root(account, 1)",  # The total expenses and the total income
        "root(account, 0)",  # the net income
    ]

    data_points: list[DataPoint] = []
    for range in input.ranges:
        for account_column in account_columns:
            query = f"""
                SELECT {account_column}, x_date_to_period_group_key('{input.period}', date), sum(position)
                FROM account ~ '^Expenses:|^Income:'
                OPEN ON {range.start}
                CLOSE ON {range.end}
                WHERE {where_clause}
                GROUP BY 1, 2
                ORDER BY 1 ASC, 2 ASC
            """
            for row in cast(
                list[tuple[str, str, Inventory]],
                input.conn.execute(query).fetchall(),  # pyright: ignore[reportUnknownMemberType]
            ):
                for position in row[2]:
                    data_points.append(
                        DataPoint(
                            account=row[0],
                            position=cast(Position, position),  # pyright: ignore[reportUnnecessaryCast]
                            range=range,
                        )
                    )

    data_points = respect_asset_class(input, data_points)
    table = pivot(input.ranges, data_points)
    print_table(table)


def cmd_balance_sheet(input: Input):
    account_column = account_level_to_column(input.account_level)
    where_clause = input.where_clause if input.where_clause is not None else "TRUE"

    data_points: list[DataPoint] = []
    for range in input.ranges:
        query = f"""
            SELECT {account_column}, sum(position)
            FROM account ~ '^Assets:|^Liabilities:'
            CLOSE ON {range.end}
            CLEAR
            WHERE {where_clause}
            GROUP BY 1
            ORDER BY 1 ASC
        """
        for row in cast(
            list[tuple[str, Inventory]],
            input.conn.execute(query).fetchall(),  # pyright: ignore[reportUnknownMemberType]
        ):
            for position in row[1]:
                data_points.append(
                    DataPoint(
                        account=row[0],
                        position=cast(Position, position),  # pyright: ignore[reportUnnecessaryCast]
                        range=range,
                    )
                )
    data_points = respect_asset_class(input, data_points)
    table = pivot(input.ranges, data_points)
    print_table(table)


def monday(d: datetime.date) -> datetime.date:
    return d + datetime.timedelta(days=-d.weekday())


def start_of_month(d: datetime.date) -> datetime.date:
    return d.replace(day=1)


def previous_month(d: datetime.date) -> datetime.date:
    assert d.day == 1
    year = d.year
    month = d.month
    if month == 1:
        year -= 1
        month = 12
    else:
        month -= 1
    return datetime.date(year=year, month=month, day=d.day)


def next_month(d: datetime.date) -> datetime.date:
    assert d.day == 1
    year = d.year
    month = d.month
    if month >= 12:
        year += 1
        month = 1
    else:
        month += 1
    return datetime.date(year=year, month=month, day=d.day)


def start_of_quarter(d: datetime.date) -> datetime.date:
    match d.month:
        case 1 | 2 | 3:
            return datetime.date(year=d.year, month=1, day=1)
        case 4 | 5 | 6:
            return datetime.date(year=d.year, month=4, day=1)
        case 7 | 8 | 9:
            return datetime.date(year=d.year, month=7, day=1)
        case 10 | 11 | 12:
            return datetime.date(year=d.year, month=10, day=1)
        case _:
            raise ValueError("unreachable")


def next_quarter(d: datetime.date) -> datetime.date:
    assert d.month in [1, 4, 7, 10]
    assert d.day == 1
    year = d.year
    month = d.month
    if month == 10:
        year += 1
        month = 1
    else:
        month += 3
    return datetime.date(year=year, month=month, day=d.day)


def previous_quarter(d: datetime.date) -> datetime.date:
    assert d.month in [1, 4, 7, 10]
    assert d.day == 1
    year = d.year
    month = d.month
    if month == 1:
        year -= 1
        month = 10
    else:
        month -= 3
    return datetime.date(year=year, month=month, day=d.day)


def parse_quarter_notation(s: str) -> datetime.date:
    parts = s.split("-")
    if len(parts) != 2:
        raise ValueError(f"`{s}` is not a valid quarter notation")
    # Verify the year is valid.
    d = datetime.date.fromisoformat(parts[0] + "-01-01")
    match parts[1]:
        case "Q1":
            return datetime.date(year=d.year, month=1, day=1)
        case "Q2":
            return datetime.date(year=d.year, month=4, day=1)
        case "Q3":
            return datetime.date(year=d.year, month=7, day=1)
        case "Q4":
            return datetime.date(year=d.year, month=10, day=1)
        case _:
            raise ValueError(f"`{s}` is not a valid quarter notation")


def start_of_year(d: datetime.date) -> datetime.date:
    return datetime.date(year=d.year, month=1, day=1)


def parse_year_notation(s: str) -> datetime.date:
    d = datetime.date.fromisoformat(s + "-01-01")
    return datetime.date(year=d.year, month=1, day=1)


def next_year(d: datetime.date) -> datetime.date:
    return datetime.date(year=d.year + 1, month=d.month, day=d.day)


def previous_year(d: datetime.date) -> datetime.date:
    return datetime.date(year=d.year - 1, month=d.month, day=d.day)


def start_of_hong_kong(d: datetime.date) -> datetime.date:
    if d.month < 4:
        return datetime.date(year=d.year - 1, month=4, day=1)
    else:
        return datetime.date(year=d.year, month=4, day=1)


def parse_hong_kong(s: str) -> datetime.date:
    d = datetime.date.fromisoformat(s)
    if d.month != 4 or d.day != 1:
        raise ValueError("date must be YYYY-04-01")
    return d


def get_ranges(
    *, period: Period, start: datetime.date, end: datetime.date
) -> list[Range]:
    ranges: list[Range] = []

    range_start = start
    while range_start < end:
        match period:
            case "daily":
                range_end = range_start + datetime.timedelta(days=1)
            case "weekly":
                range_end = range_start + datetime.timedelta(weeks=1)
            case "monthly":
                range_end = next_month(range_start)
            case "quarterly":
                range_end = next_quarter(range_start)
            case "yearly":
                range_end = next_year(range_start)
            case "hong-kong":
                range_end = next_year(range_start)
        ranges.append(Range(period=period, start=range_start, end=range_end))
        range_start = range_end

    return ranges


def get_asset_class_by_name(name: str) -> AssetClass | None:
    asset_class: AssetClass | None = None
    if name.startswith("OCC_"):
        asset_class = "derivative"
    elif name.startswith("CUSIP_"):
        asset_class = "fixed-income"
    else:
        decimal_place = get_decimal_places(name)
        if decimal_place is not None:
            asset_class = "cash"
    return asset_class


def respect_asset_class(input: Input, data_points: list[DataPoint]) -> list[DataPoint]:
    if input.asset_class is None:
        return data_points

    # Build a map for explicitly declared commodities.
    name_to_asset_class: dict[str, AssetClass] = {}
    rows = cast(
        list[tuple[str, dict[str, Any]]],  # pyright: ignore[reportExplicitAny]
        input.conn.execute("SELECT name, meta FROM #commodities").fetchall(),  # pyright: ignore[reportUnknownMemberType]
    )
    for name, meta in rows:
        asset_class: AssetClass | None = None
        if "asset_class" in meta:
            try:
                asset_class_raw = meta["asset_class"]  # pyright: ignore[reportAny]
                if not isinstance(asset_class_raw, str):
                    raise TypeError()
                asset_class = parse_asset_class(asset_class_raw)
            except (ValueError, TypeError):
                pass
        else:
            asset_class = get_asset_class_by_name(name)

        if asset_class is not None:
            name_to_asset_class[name] = asset_class

    filtered: list[DataPoint] = []
    for data_point in data_points:
        name = data_point.position.units.currency

        asset_class = name_to_asset_class.get(name)
        # If the commodity is not explicitly defined,
        # derive its asset class by looking at its name.
        if asset_class is None:
            asset_class = get_asset_class_by_name(name)

        if asset_class is None or asset_class not in input.asset_class:
            continue

        filtered.append(data_point)
    return filtered


def sort_account_lots(account_lots: list[AccountLot]) -> list[AccountLot]:
    net_income = sorted([a for a in account_lots if a.account == ""])
    total_expenses = sorted([a for a in account_lots if a.account == "Expenses"])
    total_income = sorted([a for a in account_lots if a.account == "Income"])
    expenses = sorted([a for a in account_lots if a.account.startswith("Expenses:")])
    income = sorted([a for a in account_lots if a.account.startswith("Income:")])
    assets = sorted([a for a in account_lots if a.account.startswith("Assets:")])
    liabilities = sorted(
        [a for a in account_lots if a.account.startswith("Liabilities:")]
    )
    return (
        assets
        + liabilities
        + expenses
        + total_expenses
        + income
        + total_income
        + net_income
    )


def pivot(ranges: list[Range], data_points: list[DataPoint]) -> list[list[str]]:
    # Gather a list of unique AccountLot
    account_lot_set: set[AccountLot] = set()
    for data_point in data_points:
        account_lot_set.add(data_point.account_lot)
    account_lots = sort_account_lots(list(account_lot_set))

    # Build the headers
    output: list[list[str]] = [["Account"] + [str(range) for range in ranges]]

    for account_lot in account_lots:
        row: list[str] = [str(account_lot)]
        for range in ranges:
            # Find the data point.
            found = False
            for data_point in data_points:
                if data_point.account_lot == account_lot and data_point.range == range:
                    found = str(data_point.position)
            if found:
                row.append(found)
            else:
                row.append("")
        output.append(row)

    return output


def print_table(table: list[list[str]]) -> None:
    print(
        tabulate.tabulate(
            table,
            headers="firstrow",
            tablefmt="github",
            colglobalalign="right",  # pyrefly: ignore
            headersglobalalign="left",  # pyrefly: ignore
            colalign=("left",),
        )
    )


def parse_namespace(namespace: argparse.Namespace) -> Input:
    account_level = cast(int | None, namespace.account_level)
    asset_class = cast(list[AssetClass] | None, namespace.asset_class)
    where_clause = cast(str | None, namespace.where_clause)
    filepath = cast(str, namespace.filepath)
    conn = beanquery.connect(None)  # pyright: ignore[reportUnknownMemberType]
    conn.attach(f"beancount:{filepath}")  # pyright: ignore[reportUnknownMemberType]

    start_str = cast(str | None, namespace.start)
    end_str = cast(str | None, namespace.end)
    match cast(Period, namespace.period):
        case "daily":
            match (start_str, end_str):
                case (None, None):
                    start = datetime.date.today()
                    end = start + datetime.timedelta(days=1)
                case (None, end_str):
                    end = datetime.date.fromisoformat(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    start = end + datetime.timedelta(days=-1)
                case (start_str, None):
                    start = datetime.date.fromisoformat(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = start + datetime.timedelta(days=1)
                case (start_str, end_str):
                    start = datetime.date.fromisoformat(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = datetime.date.fromisoformat(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="daily",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case "weekly":
            match (start_str, end_str):
                case (None, None):
                    today = datetime.date.today()
                    start = monday(today)
                    assert start.weekday() == 0
                    end = start + datetime.timedelta(weeks=1)
                case (None, end_str):
                    end = datetime.date.strptime(cast(str, end_str) + "-1", "%G-W%V-%u")  # pyright: ignore[reportUnnecessaryCast]
                    assert end.weekday() == 0
                    start = end + datetime.timedelta(weeks=-1)
                    assert start.weekday() == 0
                case (start_str, None):
                    start = datetime.date.strptime(
                        cast(str, start_str) + "-1",  # pyright: ignore[reportUnnecessaryCast]
                        "%G-W%V-%u",
                    )
                    assert start.weekday() == 0
                    end = start + datetime.timedelta(weeks=1)
                    assert end.weekday() == 0
                case (start_str, end_str):
                    start = datetime.date.strptime(
                        cast(str, start_str) + "-1",  # pyright: ignore[reportUnnecessaryCast]
                        "%G-W%V-%u",
                    )
                    end = datetime.date.strptime(cast(str, end_str) + "-1", "%G-W%V-%u")  # pyright: ignore[reportUnnecessaryCast]
                    assert start.weekday() == 0
                    assert end.weekday() == 0
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="weekly",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case "monthly":
            match (start_str, end_str):
                case (None, None):
                    today = datetime.date.today()
                    start = start_of_month(today)
                    end = next_month(start)
                case (None, end_str):
                    end = datetime.date.fromisoformat(cast(str, end_str) + "-01")  # pyright: ignore[reportUnnecessaryCast]
                    start = previous_month(end)
                case (start_str, None):
                    start = datetime.date.fromisoformat(cast(str, start_str) + "-01")  # pyright: ignore[reportUnnecessaryCast]
                    end = next_month(start)
                case (start_str, end_str):
                    start = datetime.date.fromisoformat(cast(str, start_str) + "-01")  # pyright: ignore[reportUnnecessaryCast]
                    end = datetime.date.fromisoformat(cast(str, end_str) + "-01")  # pyright: ignore[reportUnnecessaryCast]
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="monthly",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case "quarterly":
            match (start_str, end_str):
                case (None, None):
                    today = datetime.date.today()
                    start = start_of_quarter(today)
                    end = next_quarter(start)
                case (None, end_str):
                    end = parse_quarter_notation(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    start = previous_quarter(end)
                case (start_str, None):
                    start = parse_quarter_notation(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = next_quarter(start)
                case (start_str, end_str):
                    start = parse_quarter_notation(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = parse_quarter_notation(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="quarterly",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case "yearly":
            match (start_str, end_str):
                case (None, None):
                    today = datetime.date.today()
                    start = start_of_year(today)
                    end = next_year(start)
                case (None, end_str):
                    end = parse_year_notation(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    start = previous_year(end)
                case (start_str, None):
                    start = parse_year_notation(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = next_year(start)
                case (start_str, end_str):
                    start = parse_year_notation(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = parse_year_notation(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="yearly",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case "hong-kong":
            match (start_str, end_str):
                case (None, None):
                    today = datetime.date.today()
                    start = start_of_hong_kong(today)
                    end = next_year(start)
                case (None, end_str):
                    end = parse_hong_kong(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    start = previous_year(end)
                case (start_str, None):
                    start = parse_hong_kong(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = next_year(start)
                case (start_str, end_str):
                    start = parse_hong_kong(cast(str, start_str))  # pyright: ignore[reportUnnecessaryCast]
                    end = parse_hong_kong(cast(str, end_str))  # pyright: ignore[reportUnnecessaryCast]
                    if start >= end:
                        raise ValueError("--start must be strictly less than --end")
                case _:  # pyright: ignore[reportUnnecessaryComparison]
                    raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
            return Input(
                period="hong-kong",
                start=start,
                end=end,
                conn=conn,
                account_level=account_level,
                asset_class=asset_class,
                where_clause=where_clause,
            )
        case _:  # pyright: ignore[reportUnnecessaryComparison]
            raise ValueError("unreachable")  # pyright: ignore[reportUnreachable]


def parse_account_level(s: str) -> int:
    v = int(s, base=10)
    if v < 0:
        raise ValueError("--account-level must be nonnegative integer")
    return v


def main():
    parser = argparse.ArgumentParser(description="Generate reports on Beancount files")

    # The order is important.
    # The subcommand comes before the required filepath.
    subcommands = parser.add_subparsers(dest="subcommands", required=True)

    income_statement = subcommands.add_parser(
        "income-statement",
        aliases=["is"],
        help="Generate an income statement",
    )
    income_statement.set_defaults(command=cmd_income_statement)
    balance_sheet = subcommands.add_parser(
        "balance-sheet",
        aliases=["bs"],
        help="Generate a balance sheet",
    )
    balance_sheet.set_defaults(command=cmd_balance_sheet)

    for p in [income_statement, balance_sheet]:
        _ = p.add_argument(
            "--period",
            choices=["daily", "weekly", "monthly", "quarterly", "yearly", "hong-kong"],
            default="daily",
            help="The period of the report.",
        )
        _ = p.add_argument(
            "--start",
            help="The start of the report, e.g. 2026-01-01, 2026-W1, 2026-01, 2026-Q1, 2026",
        )
        _ = p.add_argument(
            "--end",
            help="The end of the report, e.g. 2026-01-01, 2026-W1, 2026-01, 2026-Q1, 2026",
        )
        _ = p.add_argument(
            "--account-level",
            type=parse_account_level,
            help="Truncate account to this level. If 0 is given, all accounts are truncated to 1 account.",
        )
        _ = p.add_argument(
            "--asset-class",
            choices=[
                "cash",
                "stock",
                "fixed-income",
                "derivative",
                "retirement-fund",
                "cryptocurrency",
                "property",
                "vehicle",
            ],
            action="append",
            help="If given, only show positions of the given asset class. It can be specified more than once.",
        )
        _ = p.add_argument(
            "--where-clause",
            help="Additional WHERE clause to be applied to the query.",
        )
        _ = p.add_argument("filepath", help="Path to the Beancount file")

    args = parser.parse_args()
    input = parse_namespace(args)
    cast(Subcommand, args.command)(input)


main()
