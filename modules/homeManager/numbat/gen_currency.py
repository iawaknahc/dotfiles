#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import TypedDict, cast

import requests

URL = "https://open.er-api.com/v6/latest/USD"


class Response(TypedDict):
    rates: dict[str, float]
    time_last_update_utc: str
    provider: str


if not sys.stdin.isatty():
    try:
        data = cast(Response, json.load(sys.stdin))
    except (json.JSONDecodeError, ValueError):
        # When run by launchd, stdin may be /dev/null
        data = cast(Response, requests.get(URL).json())
else:
    data = cast(Response, requests.get(URL).json())

cache = Path.home() / ".local/state/numbat/er-api-v6-usd.json"
cache.parent.mkdir(parents=True, exist_ok=True)
_ = cache.write_text(json.dumps(data, indent=2))

rates = data["rates"]

lines = cast(list[str], [])
lines.append(f"# Generated on {data['time_last_update_utc']} from {data['provider']}")
lines.append("dimension Money")
lines.append("")
lines.append('@name("USD")')
lines.append("unit USD: Money")
lines.append("")

items = list(rates.items())
lines.append("fn _from_usd(currency: String) -> Scalar =")
for i, (code, rate) in enumerate(items):
    if i == 0:
        lines.append(f'  if currency == "{code}" then {rate}')
    else:
        lines.append(f'  else if currency == "{code}" then {rate}')
lines.append('  else error("unknown currency {currency}")')
lines.append("")

for code in rates:
    if code != "USD":
        lines.append(f'@name("{code}")')
        lines.append(
            f'unit {code}: Money = if _from_usd("{code}") == 0 then 0 else USD / _from_usd("{code}")'
        )
        lines.append("")

print("\n".join(lines))
