#!/usr/bin/env python3

import json
import os
import sys
import time
import urllib.request
from datetime import datetime

# The left-hand side is ISO 4217 currencies supported by Stripe. See https://docs.stripe.com/currencies#presentment-currencies
# The right-hand side is ISO 3166 Alpha-2 country code.
CURRENCY_TO_COUNTRY = {
    "AED": "AE",
    "AFN": "AF",
    "ALL": "AL",
    "AMD": "AM",
    "ANG": "CW",
    "AOA": "AO",
    "ARS": "AR",
    "AUD": "AU",
    "AWG": "AW",
    "AZN": "AZ",
    "BAM": "BA",
    "BBD": "BB",
    "BDT": "BD",
    "BIF": "BI",
    "BMD": "BM",
    "BND": "BN",
    "BOB": "BO",
    "BRL": "BR",
    "BSD": "BS",
    "BWP": "BW",
    "BYN": "BY",
    "BZD": "BZ",
    "CAD": "CA",
    "CDF": "CD",
    "CHF": "CH",
    "CLP": "CL",
    "CNY": "CN",
    "COP": "CO",
    "CRC": "CR",
    "CVE": "CV",
    "CZK": "CZ",
    "DJF": "DJ",
    "DKK": "DK",
    "DOP": "DO",
    "DZD": "DZ",
    "EGP": "EG",
    "ETB": "ET",
    "EUR": "EU",
    "FJD": "FJ",
    "FKP": "FK",
    "GBP": "GB",
    "GEL": "GE",
    "GIP": "GI",
    "GMD": "GM",
    "GNF": "GN",
    "GTQ": "GT",
    "GYD": "GY",
    "HKD": "HK",
    "HNL": "HN",
    "HTG": "HT",
    "HUF": "HU",
    "IDR": "ID",
    "ILS": "IL",
    "INR": "IN",
    "ISK": "IS",
    "JMD": "JM",
    "JPY": "JP",
    "KES": "KE",
    "KGS": "KG",
    "KHR": "KH",
    "KMF": "KM",
    "KRW": "KR",
    "KYD": "KY",
    "KZT": "KZ",
    "LAK": "LA",
    "LBP": "LB",
    "LKR": "LK",
    "LRD": "LR",
    "LSL": "LS",
    "MAD": "MA",
    "MDL": "MD",
    "MGA": "MG",
    "MKD": "MK",
    "MMK": "MM",
    "MNT": "MN",
    "MOP": "MO",
    "MUR": "MU",
    "MVR": "MV",
    "MWK": "MW",
    "MXN": "MX",
    "MYR": "MY",
    "MZN": "MZ",
    "NAD": "NA",
    "NGN": "NG",
    "NIO": "NI",
    "NOK": "NO",
    "NPR": "NP",
    "NZD": "NZ",
    "PAB": "PA",
    "PEN": "PE",
    "PGK": "PG",
    "PHP": "PH",
    "PKR": "PK",
    "PLN": "PL",
    "PYG": "PY",
    "QAR": "QA",
    "RON": "RO",
    "RSD": "RS",
    "RUB": "RU",
    "RWF": "RW",
    "SAR": "SA",
    "SBD": "SB",
    "SCR": "SC",
    "SEK": "SE",
    "SGD": "SG",
    "SHP": "SH",
    "SLE": "SL",
    "SOS": "SO",
    "SRD": "SR",
    "STD": "ST",
    "SZL": "SZ",
    "THB": "TH",
    "TJS": "TJ",
    "TOP": "TO",
    "TRY": "TR",
    "TTD": "TT",
    "TWD": "TW",
    "TZS": "TZ",
    "UAH": "UA",
    "UGX": "UG",
    "USD": "US",
    "UYU": "UY",
    "UZS": "UZ",
    "VND": "VN",
    "VUV": "VU",
    "WST": "WS",
    "XAF": "CM",
    "XCD": "AG",
    "XCG": "CW",
    "XOF": "SN",
    "XPF": "PF",
    "YER": "YE",
    "ZAR": "ZA",
    "ZMW": "ZM",
}

# https://docs.stripe.com/currencies#zero-decimal
ZERO_DECIMAL_CURRENCIES = frozenset(
    {
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
    }
)

# https://docs.stripe.com/currencies#special-cases
ZERO_DECIMAL_CURRENCIES_SPECIAL_CASE = frozenset(
    {
        "ISK",
        "HUF",
        "TWD",
        "UGX",
    }
)

DEFAULT_TARGETS = ["USD", "CAD", "EUR", "GBP", "CHF", "AUD", "JPY", "HKD", "CNY", "TWD"]
CACHE_PATH = os.path.expanduser("~/.local/state/alfred-cur/er-api-v6-usd.json")
API_URL = "https://open.er-api.com/v6/latest/USD"
CACHE_TTL = 12 * 3600  # 12 hours


def flag_emoji(currency_code: str) -> str:
    country = CURRENCY_TO_COUNTRY.get(currency_code.upper(), "")
    if not country:
        return ""
    return "".join(chr(0x1F1E6 + ord(c) - ord("A")) for c in country.upper())


def load_rates() -> tuple[dict, str]:
    """Return (rates dict, retrieved_at string). Caches to disk for 12 hours."""
    os.makedirs(os.path.dirname(CACHE_PATH), exist_ok=True)

    cache_data = None
    cache_valid = False

    if os.path.exists(CACHE_PATH):
        try:
            with open(CACHE_PATH) as f:
                cache_data = json.load(f)
            if time.time() - os.path.getmtime(CACHE_PATH) < CACHE_TTL:
                cache_valid = True
        except Exception:
            pass

    if not cache_valid:
        try:
            with urllib.request.urlopen(API_URL, timeout=5) as resp:
                cache_data = json.load(resp)
            with open(CACHE_PATH, "w") as f:
                json.dump(cache_data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            if cache_data is None:
                raise RuntimeError(f"Failed to fetch rates: {e}")
            # Fall through and use stale cache

    mtime = os.path.getmtime(CACHE_PATH)
    retrieved_at = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S")
    return cache_data.get("rates", {}), retrieved_at


def convert(amount: float, src: str, dst: str, rates: dict) -> float:
    """Convert amount from src currency to dst via USD base rates."""
    if src not in rates:
        raise ValueError(f"Unknown currency: {src}")
    if dst not in rates:
        raise ValueError(f"Unknown currency: {dst}")
    return amount / rates[src] * rates[dst]


def fmt_rate(rate: float) -> str:
    """Format an exchange rate with enough precision to be meaningful."""
    if rate >= 100:
        return f"{rate:,.4f}".rstrip("0").rstrip(".")
    elif rate >= 1:
        return f"{rate:.4f}".rstrip("0").rstrip(".")
    else:
        return f"{rate:.6f}".rstrip("0").rstrip(".")


def fmt(amount: float, currency: str = "") -> str:
    if (
        currency.upper() in ZERO_DECIMAL_CURRENCIES
        or currency.upper() in ZERO_DECIMAL_CURRENCIES_SPECIAL_CASE
    ):
        return f"{round(amount):,}"
    if amount >= 10000:
        return f"{amount:,.2f}"
    return f"{amount:.2f}"


def make_item(
    amount: float, src: str, dst: str, rates: dict, retrieved_at: str
) -> dict:
    converted = convert(amount, src, dst, rates)
    flag_src = flag_emoji(src)
    flag_dst = flag_emoji(dst)
    src_label = f"{flag_src} {src}".strip() if flag_src else src
    dst_label = f"{flag_dst} {dst}".strip() if flag_dst else dst
    title = f"{src_label} {fmt(amount, src)} = {dst_label} {fmt(converted, dst)}"
    src_per_usd = 1.0 / rates[src]  # 1 SRC = ? USD
    usd_per_dst = rates[dst]  # 1 USD = ? DST
    src_per_dst = src_per_usd * usd_per_dst  # 1 SRC = ? DST (cross rate)
    subtitle_rates = f"{src}/USD = {fmt_rate(src_per_usd)}, USD/{dst} = {fmt_rate(usd_per_dst)}, {src}/{dst} ~= {fmt_rate(src_per_dst)}"
    subtitle = f"Rates retrieved at {retrieved_at}; Press ⌘ for detailed rates"
    return {
        "title": title,
        "subtitle": subtitle,
        "arg": fmt(converted, dst),
        "mods": {
            "cmd": {
                "subtitle": subtitle_rates,
                "arg": subtitle_rates,
            },
        },
    }


def result(items: list) -> None:
    print(json.dumps({"items": items}, ensure_ascii=False, indent=2))


def error(message: str) -> None:
    result([{"title": message, "valid": False}])


def main() -> None:
    query = sys.argv[1].strip() if len(sys.argv) > 1 else ""
    tokens = query.split()

    # Parse: [amount] [src] [dst]  — amount defaults to 1, src defaults to USD
    try:
        amount = float(tokens[0]) if tokens else 1.0
        rest = tokens[1:] if tokens else []
    except ValueError:
        amount = 1.0
        rest = tokens

    src = rest[0].upper() if len(rest) >= 1 else "USD"
    targets = (
        [rest[1].upper()]
        if len(rest) >= 2
        else [t for t in DEFAULT_TARGETS if t != src]
    )

    try:
        rates, retrieved_at = load_rates()
    except Exception as e:
        error(str(e))
        return

    items = []
    for dst in targets:
        try:
            items.append(make_item(amount, src, dst, rates, retrieved_at))
        except ValueError as e:
            items.append({"title": str(e), "valid": False})

    result(items)


if __name__ == "__main__":
    main()
