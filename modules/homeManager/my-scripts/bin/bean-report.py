#!/usr/bin/env python3
import argparse
import datetime
from dataclasses import dataclass
from decimal import Decimal
from typing import Any, Literal, NamedTuple, Self, cast, override

import beanquery  # pyright: ignore[reportMissingTypeStubs]
import pyxirr
import tabulate
from beancount.core import convert, data, prices
from beancount.core.amount import Amount
from beancount.core.inventory import Inventory
from beancount.core.position import Cost, Position
from beancount.parser.grammar import ValueType
from beanquery import query_env  # pyright: ignore[reportMissingTypeStubs]
from beanquery.sources.beancount import (  # pyright: ignore[reportMissingTypeStubs]
    Table,
    _typed_namedtuple_to_columns,  # pyright: ignore[reportPrivateUsage, reportUnknownVariableType]
)


# Bean-query does not expose this table.
# So we do it ourselves.
class QueriesTable(Table):
    name = "queries"  # pyright: ignore[reportUnannotatedClassAttribute]
    datatype = data.Query  # pyright: ignore[reportUnannotatedClassAttribute]
    columns = _typed_namedtuple_to_columns(datatype)  # pyright: ignore[reportUnknownVariableType, reportUnannotatedClassAttribute]


# Bean-query does not expose this table.
# So we do it ourselves.
class CustomsTable(Table):
    name = "customs"  # pyright: ignore[reportUnannotatedClassAttribute]
    datatype = data.Custom  # pyright: ignore[reportUnannotatedClassAttribute]
    columns = _typed_namedtuple_to_columns(datatype)  # pyright: ignore[reportUnknownVariableType, reportUnannotatedClassAttribute]


Subcommand = (
    Literal["income-statement"]
    | Literal["balance-sheet"]
    | Literal["unrealized-gains-and-losses"]
    | Literal["xirr"]
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


class Pair(NamedTuple):
    base: str
    quote: str


def get_price_map(conn: beanquery.Connection) -> prices.PriceMap:
    # Based on observation, the prices table has a special property `price_map` which is an instance of prices.PriceMap.
    # https://github.com/beancount/beanquery/blob/v0.2.0/beanquery/sources/beancount.py#L179
    PricesTable = NamedTuple("PricesTable", [("price_map", prices.PriceMap)])  # pyright: ignore[reportAny]
    tables = cast(
        dict[
            Literal["prices"],
            PricesTable,
        ],
        conn.tables,
    )
    return tables["prices"].price_map


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
class InputXIRR:
    portfolio: str | None
    conn: beanquery.Connection

    def __init__(self, *, portfolio: str | None, conn: beanquery.Connection):
        self.portfolio = portfolio
        self.conn = conn

    @classmethod
    def from_namespace(cls, namespace: argparse.Namespace) -> Self:
        filepath = cast(str, namespace.filepath)
        conn = beanquery.connect(None)  # pyright: ignore[reportUnknownMemberType]
        conn.attach(f"beancount:{filepath}")  # pyright: ignore[reportUnknownMemberType]
        portfolio = cast(str | None, namespace.portfolio)
        return cls(portfolio=portfolio, conn=conn)


@dataclass
class InputWithAsOf:
    as_of: datetime.date
    conn: beanquery.Connection

    def __init__(self, *, as_of: datetime.date, conn: beanquery.Connection):
        self.as_of = as_of
        self.conn = conn

    @classmethod
    def from_namespace(cls, namespace: argparse.Namespace) -> Self:
        as_of_str = cast(str | None, namespace.as_of)
        if as_of_str is None:
            as_of = datetime.date.today()
        else:
            as_of = datetime.date.fromisoformat(as_of_str)

        filepath = cast(str, namespace.filepath)
        conn = beanquery.connect(None)  # pyright: ignore[reportUnknownMemberType]
        conn.attach(f"beancount:{filepath}")  # pyright: ignore[reportUnknownMemberType]

        return cls(as_of=as_of, conn=conn)


@dataclass
class InputWithPeriodStartEnd:
    period: Period
    start: datetime.date
    end: datetime.date
    conn: beanquery.Connection
    account_level: int | None
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
        where_clause: str | None,
    ):
        self.period = period
        self.start = start
        self.end = end
        self.conn = conn
        self.account_level = account_level
        self.ranges = get_ranges(period=period, start=start, end=end)
        self.where_clause = where_clause

    @classmethod
    def get_default_where_clause(
        cls, conn: beanquery.Connection, command: str
    ) -> str | None:
        customs_query = """
            SELECT meta, values
            FROM #customs
            WHERE type = 'bean-report.py'
        """
        for row in cast(
            list[
                tuple[
                    data.Meta,
                    list[ValueType],
                ]
            ],
            conn.execute(customs_query).fetchall(),  # pyright: ignore[reportUnknownMemberType]
        ):
            value_types = row[1]
            if len(value_types) == 1 and value_types[0].value == command:  # pyright: ignore[reportAny]
                meta = row[0]
                try:
                    default_where_clause = meta["default_where_clause"]  # pyright: ignore[reportAny]
                    if isinstance(default_where_clause, str):
                        return default_where_clause
                except KeyError:
                    pass

    @classmethod
    def from_namespace(cls, command: str, namespace: argparse.Namespace) -> Self:
        account_level = cast(int | None, namespace.account_level)
        where_clause = cast(str | None, namespace.where_clause)
        filepath = cast(str, namespace.filepath)
        conn = beanquery.connect(None)  # pyright: ignore[reportUnknownMemberType]
        conn.attach(f"beancount:{filepath}")  # pyright: ignore[reportUnknownMemberType]

        if where_clause is None:
            where_clause = cls.get_default_where_clause(conn, command)

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
                return cls(
                    period="daily",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
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
                        end = datetime.date.strptime(
                            cast(str, end_str) + "-1",  # pyright: ignore[reportUnnecessaryCast]
                            "%G-W%V-%u",
                        )
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
                        end = datetime.date.strptime(
                            cast(str, end_str) + "-1",  # pyright: ignore[reportUnnecessaryCast]
                            "%G-W%V-%u",
                        )
                        assert start.weekday() == 0
                        assert end.weekday() == 0
                        if start >= end:
                            raise ValueError("--start must be strictly less than --end")
                    case _:  # pyright: ignore[reportUnnecessaryComparison]
                        raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
                return cls(
                    period="weekly",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
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
                        start = datetime.date.fromisoformat(
                            cast(str, start_str) + "-01"  # pyright: ignore[reportUnnecessaryCast]
                        )
                        end = next_month(start)
                    case (start_str, end_str):
                        start = datetime.date.fromisoformat(
                            cast(str, start_str) + "-01"  # pyright: ignore[reportUnnecessaryCast]
                        )
                        end = datetime.date.fromisoformat(cast(str, end_str) + "-01")  # pyright: ignore[reportUnnecessaryCast]
                        if start >= end:
                            raise ValueError("--start must be strictly less than --end")
                    case _:  # pyright: ignore[reportUnnecessaryComparison]
                        raise TypeError("unreachable")  # pyright: ignore[reportUnreachable]
                return cls(
                    period="monthly",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
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
                return cls(
                    period="quarterly",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
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
                return cls(
                    period="yearly",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
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
                return cls(
                    period="hong-kong",
                    start=start,
                    end=end,
                    conn=conn,
                    account_level=account_level,
                    where_clause=where_clause,
                )
            case _:  # pyright: ignore[reportUnnecessaryComparison]
                raise ValueError("unreachable")  # pyright: ignore[reportUnreachable]


def account_level_to_column(account_level: int | None) -> str:
    if account_level is None:
        return "account"
    return f"root(account, {account_level})"


@query_env.function([str], dict, pass_context=True, name="account_meta")  # pyright: ignore[reportUnknownMemberType]
@query_env.function([str, str], object, pass_context=True, name="account_meta")  # pyright: ignore[reportUnknownMemberType]
def account_meta(
    context: beanquery.Connection, account: str, key: str | None = None
) -> data.Meta | object | None:
    accounts = cast(
        dict[str, tuple[data.Open | None, data.Close | None]],
        context.tables["accounts"].accounts,  # pyright: ignore[reportArgumentType, reportAttributeAccessIssue]  # ty:ignore[unresolved-attribute]
    )
    try:
        open_directive, _ = accounts[account]
        if open_directive is not None:
            if key is not None:
                return open_directive.meta.get(key)
            return open_directive.meta
    except KeyError:
        pass
    return None


@query_env.function([str, datetime.date], str)  # pyright: ignore[reportUnknownMemberType]
def x_date_to_period_group_key(period: Period, d: datetime.date) -> str:
    return date_to_period_group_key(period, d)


# Combine 2 positions by deriving their average per-unit cost.
# The input positions must have cost being Cost.
# The output position will always have cost being Cost.
def combine_positions(p1: Position, p2: Position) -> Position:
    assert p1.cost is not None
    assert p2.cost is not None
    assert p1.units.number is not None
    assert p2.units.number is not None
    assert p1.units.currency == p2.units.currency
    assert p1.cost.currency == p2.cost.currency

    base = p1.units.currency
    quote = p1.cost.currency

    units_number = p1.units.number + p2.units.number

    c = Decimal(0)
    c += p1.cost.number * p1.units.number
    c += p2.cost.number * p2.units.number
    if units_number == Decimal(0):
        number_per = Decimal(0)
    else:
        number_per = c / units_number

    return Position(
        units=Amount(number=units_number, currency=base),
        cost=Cost(
            number=number_per,
            currency=quote,
            date=cast(Any, None),  # pyright: ignore[reportExplicitAny]
            label=None,
        ),
    )


@query_env.function([Inventory], Inventory)  # pyright: ignore[reportUnknownMemberType]
def x_avg_cost(inv: Inventory) -> Inventory:
    currency_to_position: dict[str, Position] = {}
    pair_to_position: dict[Pair, Position] = {}
    for p in inv:
        p = cast(Position, p)  # pyright: ignore[reportUnnecessaryCast]
        if p.cost is None:
            try:
                existing = currency_to_position[p.units.currency]
            except KeyError:
                existing = Position(
                    units=Amount(number=Decimal(0), currency=p.units.currency),
                    cost=None,
                )
            assert existing.units.number is not None
            assert p.units.number is not None
            currency_to_position[existing.units.currency] = Position(
                units=Amount(
                    number=existing.units.number + p.units.number,
                    currency=existing.units.currency,
                ),
                cost=None,
            )
        else:
            base = p.units.currency
            quote = p.cost.currency
            pair = Pair(base=base, quote=quote)
            try:
                existing = pair_to_position[pair]
            except KeyError:
                existing = Position(
                    units=Amount(number=Decimal(0), currency=base),
                    cost=Cost(
                        number=Decimal(0),
                        currency=quote,
                        date=cast(Any, None),  # pyright: ignore[reportExplicitAny]
                        label=None,
                    ),
                )
            pair_to_position[pair] = combine_positions(existing, p)
    out = Inventory()
    for position in currency_to_position.values():
        _ = out.add_position(position)
    for position in pair_to_position.values():
        # It is observed that cost is always of instance Cost.
        # Beancount will take care of converting CostSpec to Cost.
        assert position.cost is not None
        assert isinstance(position.cost, Cost)
        _ = out.add_position(position)
    return out


@dataclass
class Portfolio:
    name: str
    cash_flow_query_name: str
    net_worth_query_name: str
    cash_flow_query: data.Query | None
    net_worth_query: data.Query | None

    @classmethod
    def from_row(cls, row: tuple[data.Meta, list[ValueType]]) -> Self:
        meta = row[0]
        value_types = row[1]
        portfolio_name = str(value_types[1].value)  # pyright: ignore[reportAny]
        try:
            cash_flow_query_name = meta["cash_flow_query"]  # pyright: ignore[reportAny]
            if not isinstance(cash_flow_query_name, str):
                raise TypeError(
                    f"cash_flow_query must be a string in portfolio `{portfolio_name}`"
                )
        except KeyError:
            raise ValueError(
                f"cash_flow_query must be defined in portfolio `{portfolio_name}`"
            )
        try:
            net_worth_query_name = meta["net_worth_query"]  # pyright: ignore[reportAny]
            if not isinstance(net_worth_query_name, str):
                raise TypeError(
                    f"net_worth_query must be a string in portfolio `{portfolio_name}`"
                )
        except KeyError:
            raise ValueError(
                f"net_worth_query must be defined in portfolio `{portfolio_name}`"
            )
        return cls(
            name=portfolio_name,
            cash_flow_query_name=cash_flow_query_name,
            net_worth_query_name=net_worth_query_name,
            cash_flow_query=None,
            net_worth_query=None,
        )


def cmd_xirr(input: InputXIRR):
    # See what portfolio are defined.
    portfolios: list[Portfolio] = []
    customs_query = """
        SELECT meta, values
        FROM #customs
        WHERE type = 'bean-report.py'
    """
    for row in cast(
        list[
            tuple[
                data.Meta,
                list[ValueType],
            ]
        ],
        input.conn.execute(customs_query).fetchall(),  # pyright: ignore[reportUnknownMemberType]
    ):
        value_types = row[1]
        if len(value_types) == 2 and value_types[0].value == "xirr":  # pyright: ignore[reportAny]
            portfolios.append(Portfolio.from_row(row))

    # Gather the queries
    query_by_name: dict[str, data.Query] = {}
    queries_query = """
        SELECT meta, date, name, query_string
        FROM #queries
    """
    for row in cast(
        list[tuple[data.Meta, datetime.date, str, str]],
        input.conn.execute(queries_query).fetchall(),  # pyright: ignore[reportUnknownMemberType]
    ):
        meta = row[0]
        date = row[1]
        name = row[2]
        query_string = row[3]
        query = data.Query(meta=meta, date=date, name=name, query_string=query_string)
        query_by_name[name] = query

    for portfolio in portfolios:
        try:
            cash_flow_query = query_by_name[portfolio.cash_flow_query_name]
        except KeyError:
            raise ValueError(
                f"The query `{portfolio.cash_flow_query_name}` referenced by portfolio `{portfolio.name}` is missing"
            )
        try:
            net_worth_query = query_by_name[portfolio.net_worth_query_name]
        except KeyError:
            raise ValueError(
                f"The query `{portfolio.net_worth_query_name}` referenced by portfolio `{portfolio.name}` is missing"
            )
        portfolio.cash_flow_query = cash_flow_query
        portfolio.net_worth_query = net_worth_query

    # The user did not specify which portfolio to evaluate.
    # Print them out to let the user to pick.
    if input.portfolio is None:
        for portfolio in portfolios:
            print(portfolio.name)
        return

    # Otherwise, calculate the XIRR of the portfolio.
    portfolio = next(iter([p for p in portfolios if p.name == input.portfolio]))
    if portfolio is None:  # pyright: ignore[reportUnnecessaryComparison]
        raise ValueError(f"portfolio `{input.portfolio}` not found")

    assert portfolio.cash_flow_query is not None
    assert portfolio.net_worth_query is not None

    cash_flows: list[tuple[datetime.date, Amount]] = []
    for cash_flow in cast(
        list[tuple[datetime.date, Amount | Position]],
        input.conn.execute(portfolio.cash_flow_query.query_string).fetchall(),  # pyright: ignore[reportUnknownMemberType]
    ):
        if (
            len(cash_flow) != 2
            or not isinstance(cash_flow[0], datetime.date)  # pyright: ignore[reportUnnecessaryIsInstance]
            or (
                not isinstance(cash_flow[1], Amount)
                and not isinstance(cash_flow[1], Position)  # pyright: ignore[reportUnnecessaryIsInstance]
            )
        ):
            raise TypeError(
                "cash_flow_query is expected to return a row of (datetime.date, Position)"
            )
        if isinstance(cash_flow[1], Position):
            amount = cash_flow[1].units
        else:
            amount = cash_flow[1]

        if len(cash_flows) != 0:
            first = cash_flows[0]
            if first[1].currency != amount.currency:
                raise ValueError(
                    f"expected all cash flows in `{portfolio.cash_flow_query_name}` to have the currency {first[1].currency}"
                )
        cash_flows.append((cash_flow[0], amount))
    if len(cash_flows) <= 0:
        raise ValueError(
            f"expected `{portfolio.cash_flow_query_name}` to return non-empty cash flows"
        )

    results = cast(
        list[tuple[Amount | Position | Inventory]],
        input.conn.execute(portfolio.net_worth_query.query_string).fetchall(),  # pyright: ignore[reportUnknownMemberType]
    )
    if len(results) != 1:
        raise ValueError(
            f"expected `{portfolio.net_worth_query_name}` to return exactly one row"
        )
    net_worth = results[0]
    if len(net_worth) != 1:
        raise TypeError(
            f"expected `{portfolio.net_worth_query_name}` to return a row of (Amount | Position | Inventory)"
        )

    amount_or_position_inventory = net_worth[0]
    if isinstance(amount_or_position_inventory, Inventory):
        if len(amount_or_position_inventory) != 1:
            raise ValueError(
                f"expected `{portfolio.net_worth_query_name}` to return an Inventory of exactly one Position"
            )
        amount = amount_or_position_inventory.get_positions()[0].units
    elif isinstance(amount_or_position_inventory, Position):
        amount = amount_or_position_inventory.units
    else:
        amount = amount_or_position_inventory
    assert amount is not None
    assert amount.number is not None
    if amount.number <= Decimal(0):
        raise ValueError(
            f"expected `{portfolio.net_worth_query_name}` to return a positive amount"
        )

    if amount.currency != cash_flows[0][1].currency:
        raise ValueError(
            f"expected `{portfolio.net_worth_query_name}` to return an Inventory / Position / Amount of currency {cash_flows[0][1].currency}"
        )

    today = datetime.date.today()
    cash_flows.append((today, amount))

    pyxirr_cash_flows = [
        (cash_flow[0], cast(Decimal, cash_flow[1].number)) for cash_flow in cash_flows
    ]
    percentage = pyxirr.xirr(pyxirr_cash_flows)
    if percentage is None:
        raise ValueError("failed to find XIRR")

    xirr_value = (Decimal(percentage) * Decimal(100)).quantize(Decimal("0.00"))
    table: list[list[str]] = [["Date / XIRR", "Cash flow"]]
    for cash_flow in cash_flows:
        amount = format_amount(input.conn, cash_flow[1])
        table.append([str(cash_flow[0]), str(amount)])
    table.append(["XIRR", f"{xirr_value}%"])
    print_table(table)


def cmd_income_statement(input: InputWithPeriodStartEnd):
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

    table = pivot(input.ranges, data_points)
    print_table(table)


def cmd_balance_sheet(input: InputWithPeriodStartEnd):
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
    table = pivot(input.ranges, data_points)
    print_table(table)


def format_amount(conn: beanquery.Connection, amount: Amount) -> Amount:
    for currency, d in cast(
        dict[str, Decimal], conn.options["display_precision"]
    ).items():
        if amount.currency == currency:
            if amount.number is not None:
                amount = Amount(number=amount.number.quantize(d), currency=currency)
    return amount


def cmd_unrealized_gains_and_losses(input: InputWithAsOf):
    table_header: tuple[str, str, str, str, str] = (
        f"As of {input.as_of.isoformat()}",
        "Position",
        "At cost",
        "Market",
        "Unrealized P/L",
    )
    table_data: list[tuple[str, Position, Amount, Amount | None, Amount | None]] = []
    price_map = get_price_map(input.conn)

    close_date = input.as_of + datetime.timedelta(days=1)
    query = f"""
        SELECT account, x_avg_cost(sum(position))
        FROM account ~ '^Assets:'
        CLOSE ON {close_date}
        WHERE position.cost IS NOT NULL
        GROUP BY 1
        ORDER BY 1 ASC
    """
    for row in cast(list[tuple[str, Inventory]], input.conn.execute(query).fetchall()):  # pyright: ignore[reportUnknownMemberType]
        account = row[0]
        inv = row[1]
        for position in inv:
            position = cast(Position, position)  # pyright: ignore[reportUnnecessaryCast]
            cost = position.cost
            # The `WHERE position.cost IS NOT NULL` should do its job.
            # We want to skip positions that is not held at cost.
            # They are not meaningful in this report.
            assert cost is not None
            at_cost = cast(Amount, convert.get_cost(position))  # pyright: ignore[reportUnknownMemberType]
            assert at_cost.number is not None
            at_cost = format_amount(input.conn, at_cost)
            assert at_cost.number is not None

            gain_or_loss: Amount | None = None
            market_value = cast(
                Amount,
                convert.convert_position(  # pyright: ignore[reportUnknownMemberType]
                    position, cost.currency, price_map, input.as_of
                ),
            )
            # Price information is unavailable.
            if market_value.currency != cost.currency:
                market_value = None
            else:
                assert market_value.number is not None
                market_value = format_amount(input.conn, market_value)
                assert market_value.number is not None
                gain_or_loss = Amount(
                    number=market_value.number - at_cost.number,
                    currency=cost.currency,
                )

            table_data.append((account, position, at_cost, market_value, gain_or_loss))

    table: list[list[str]] = []
    table.append(list(table_header))
    for account, position, at_cost, market_value, gain_or_loss in table_data:
        table.append(
            [
                account,
                str(position),
                str(at_cost),
                "" if market_value is None else str(market_value),
                "" if gain_or_loss is None else str(gain_or_loss),
            ]
        )
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


def parse_account_level(s: str) -> int:
    v = int(s, base=10)
    if v < 0:
        raise ValueError("--account-level must be nonnegative integer")
    return v


def main():
    parser = argparse.ArgumentParser(description="Generate reports on Beancount files")

    # The order is important.
    # The subcommand comes before the required filepath.
    subcommand = parser.add_subparsers(dest="subcommand", required=True)

    income_statement = subcommand.add_parser(
        "income-statement",
        aliases=["is"],
        help="Generate an income statement",
    )
    _ = income_statement.set_defaults(command="income-statement")
    balance_sheet = subcommand.add_parser(
        "balance-sheet",
        aliases=["bs"],
        help="Generate a balance sheet",
    )
    _ = balance_sheet.set_defaults(command="balance-sheet")
    unrealized_gains_and_losses = subcommand.add_parser(
        "unrealized-gains-and-losses",
        aliases=["upnl"],
        help="Generate a report on unrealized gains and losses",
    )
    _ = unrealized_gains_and_losses.set_defaults(command="unrealized-gains-and-losses")
    xirr = subcommand.add_parser(
        "xirr",
        help="Calculate XIRR",
    )
    _ = xirr.set_defaults(command="xirr")

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
            "--where-clause",
            help="Additional WHERE clause to be applied to the query.",
        )

    for p in [unrealized_gains_and_losses]:
        _ = p.add_argument(
            "--as-of",
            help="The date of the report, e.g. 2026-01-01",
        )

    for p in [balance_sheet, income_statement, unrealized_gains_and_losses, xirr]:
        _ = p.add_argument("filepath", help="Path to the Beancount file")

    for p in [xirr]:
        _ = p.add_argument(
            "--portfolio", help="The portfolio. It is defined in your Beancount file."
        )

    args = parser.parse_args()
    match cast(Subcommand, args.command):
        case "income-statement":
            cmd_income_statement(
                InputWithPeriodStartEnd.from_namespace("income-statement", args)
            )
        case "balance-sheet":
            cmd_balance_sheet(
                InputWithPeriodStartEnd.from_namespace("balance-sheet", args)
            )
        case "unrealized-gains-and-losses":
            cmd_unrealized_gains_and_losses(InputWithAsOf.from_namespace(args))
        case "xirr":
            cmd_xirr(InputXIRR.from_namespace(args))


main()
