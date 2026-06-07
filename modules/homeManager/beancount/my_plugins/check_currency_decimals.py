from decimal import Decimal
from typing import NamedTuple

from beancount import Amount, Directive, Meta, Posting, Transaction

from my_plugins.currencies import (  # pyright: ignore[reportMissingTypeStubs]
    get_decimal_places,
)


class PluginError(NamedTuple):
    source: Meta | None
    message: str
    entry: Transaction | None


def _count_decimal_places(value: Decimal) -> int:
    _, _, exponent = value.as_tuple()
    # exponent is either a negative number, 0, "n", "N", or "F"
    #
    # Decimal("inf") => "F"
    # Decimal("NaN") => "n"
    # Decimal("sNaN") => "N"
    # Decimal("30.00") => -2
    # Decimal("30") => 0
    if isinstance(exponent, int):
        if exponent < 0:
            return abs(exponent)
        assert exponent == 0
        return 0
    raise ValueError(
        f"{value} is special number that typically does not appear in Beancount"
    )


def validate_amount(
    entry: Transaction, posting: Posting, amount: Amount
) -> PluginError | None:
    if amount.number is not None:
        currency = amount.currency
        allowed = get_decimal_places(currency)
        if allowed is not None:
            decimals = _count_decimal_places(amount.number)
            if decimals > allowed:
                return PluginError(
                    source=posting.meta,
                    message=(
                        f"{amount} has {decimals} decimal places, "
                        f"but {currency} only supports {allowed} decimal places."
                    ),
                    entry=entry,
                )
    return None


def plugin(
    entries: list[Directive], _unused_options: dict[str, None] | None
) -> tuple[list[Directive], list[PluginError]]:
    errors: list[PluginError] = []
    for entry in entries:
        if isinstance(entry, Transaction):
            # This plugin validates transactions satisfying these conditions:
            # 1. The transaction has at least one postings.
            # 2. All postings have no cost or price attached to them.
            # 3. The commodity of all postings is a currency.

            if len(entry.postings) == 0:  # Condition 1
                continue

            skip = False
            for posting in entry.postings:
                if posting.cost is not None:  # Condition 2
                    skip = True
                    break
                if posting.price is not None:  # Condition 2
                    skip = True
                    break
                if posting.units is not None:
                    decimal_place = get_decimal_places(posting.units.currency)
                    if decimal_place is None:  # Condition 3
                        skip = True
                        break
            if skip:
                continue

            # If we reach here, the transaction is subject to validation.
            for posting in entry.postings:
                if posting.units is not None:
                    err = validate_amount(entry, posting, posting.units)
                    if err is not None:
                        errors.append(err)

    return entries, errors


__plugins__ = (plugin,)
