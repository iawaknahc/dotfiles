from decimal import Decimal
from typing import NamedTuple

from beancount import Amount, Directive, Meta, Posting, Transaction


class PluginError(NamedTuple):
    source: Meta | None
    message: str
    entry: Transaction | None


TWO_DECIMAL_CURRENCIES: frozenset[str] = frozenset(
    (
        "AED",
        "AFN",
        "ALL",
        "AMD",
        "ANG",
        "AOA",
        "ARS",
        "AUD",
        "AWG",
        "AZN",
        "BAM",
        "BBD",
        "BDT",
        "BMD",
        "BND",
        "BOB",
        "BRL",
        "BSD",
        "BWP",
        "BYN",
        "BZD",
        "CAD",
        "CDF",
        "CHF",
        "COP",
        "CRC",
        "CVE",
        "CZK",
        "DOP",
        "DZD",
        "EGP",
        "ETB",
        "EUR",
        "FJD",
        "FKP",
        "GEL",
        "GIP",
        "GMD",
        "GTQ",
        "GYD",
        "HKD",
        "HNL",
        "HTG",
        "HUF",
        "IDR",
        "ILS",
        "INR",
        "ISK",
        "JMD",
        "KES",
        "KGS",
        "KHR",
        "KYD",
        "KZT",
        "LAK",
        "LBP",
        "LKR",
        "LRD",
        "LSL",
        "MAD",
        "MDL",
        "MKD",
        "MMK",
        "MNT",
        "MOP",
        "MUR",
        "MVR",
        "MWK",
        "MXN",
        "MYR",
        "MZN",
        "NAD",
        "NGN",
        "NIO",
        "NPR",
        "NZD",
        "PAB",
        "PEN",
        "PGK",
        "PHP",
        "PKR",
        "PLN",
        "QAR",
        "RON",
        "RSD",
        "RUB",
        "SAR",
        "SBD",
        "SCR",
        "SEK",
        "SGD",
        "SHP",
        "SLE",
        "SOS",
        "SRD",
        "STD",
        "SZL",
        "THB",
        "TJS",
        "TOP",
        "TRY",
        "TTD",
        "TWD",
        "TZS",
        "UAH",
        "UYU",
        "UZS",
        "WST",
        "XCD",
        "XCG",
        "YER",
        "ZAR",
        "ZMW",
    )
)

ZERO_DECIMAL_CURRENCIES: frozenset[str] = frozenset(
    (
        "BIF",
        "CLP",
        "DJF",
        "GNF",
        "JPY",
        "KMF",
        "KRW",
        "MGA",
        "PYG",
        "RWF",
        "UGX",
        "VND",
        "VUV",
        "XAF",
        "XOF",
        "XPF",
    )
)

SPECIAL_CASES_CURRENCIES: frozenset[str] = frozenset(
    (
        "ISK",
        "HUF",
        "TWD",
        "UGX",
    )
)


def _get_decimal_places(currency: str) -> int | None:
    if currency in SPECIAL_CASES_CURRENCIES:
        return 0
    if currency in ZERO_DECIMAL_CURRENCIES:
        return 0
    if currency in TWO_DECIMAL_CURRENCIES:
        return 2
    return None


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
        allowed = _get_decimal_places(currency)
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
                    decimal_place = _get_decimal_places(posting.units.currency)
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
