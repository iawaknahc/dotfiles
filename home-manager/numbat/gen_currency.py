#!/usr/bin/env python3

import json
import sys
import urllib.request
from pathlib import Path

URL = "https://open.er-api.com/v6/latest/USD"

if not sys.stdin.isatty():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        # When run by launchd, stdin may be /dev/null
        with urllib.request.urlopen(URL) as resp:
            data = json.load(resp)
else:
    with urllib.request.urlopen(URL) as resp:
        data = json.load(resp)

cache = Path.home() / ".local/state/numbat/er-api-v6-usd.json"
cache.parent.mkdir(parents=True, exist_ok=True)
cache.write_text(json.dumps(data, indent=2))

rates = data["rates"]

lines = []
lines.append(f'# Generated on {data["time_last_update_utc"]} from {data["provider"]}')
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
        lines.append(f'unit {code}: Money = USD / _from_usd("{code}")')
        lines.append("")

print("\n".join(lines))
