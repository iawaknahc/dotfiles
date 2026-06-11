from decimal import Decimal
from typing import Literal

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
        "USD",
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


def get_decimal_places(currency: str) -> Literal[0] | Literal[2] | None:
    if currency in SPECIAL_CASES_CURRENCIES:
        return 0
    if currency in ZERO_DECIMAL_CURRENCIES:
        return 0
    if currency in TWO_DECIMAL_CURRENCIES:
        return 2
    return None


def get_decimal_for_quantization(currency: str) -> Decimal | None:
    match get_decimal_places(currency):
        case None:
            return None
        case 0:
            return Decimal("1")
        case 2:
            return Decimal("0.01")
