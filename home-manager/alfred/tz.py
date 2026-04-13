#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Dict
from zoneinfo import ZoneInfo

import pytz
import tzlocal

FZF = os.environ.get("FZF", "fzf")


local_timezone = tzlocal.get_localzone()
if not isinstance(local_timezone, ZoneInfo):
    raise ValueError("This script can only work with ZoneInfo")


now_local = datetime.now().astimezone(local_timezone)

timezone_name_to_alpha2: dict[str, str] = {}
for alpha2, names in pytz.country_timezones.items():
    for timezone_name in names:
        timezone_name_to_alpha2[timezone_name] = alpha2

timezone_names = list(timezone_name_to_alpha2.keys())


@dataclass
class Timezone:
    name: str
    tzinfo: ZoneInfo

    def __init__(self, name: str):
        self.name = name
        self.tzinfo = ZoneInfo(name)

    @property
    def alpha2(self) -> str:
        return timezone_name_to_alpha2[self.name]

    @property
    def region_name_in_english(self) -> str:
        return pytz.country_names[self.alpha2]

    @classmethod
    def restore_from_line(cls, line: str) -> Timezone:
        parts = line.split(" ")
        name = parts[0]
        return cls(name)

    @classmethod
    def from_dt(cls, dt: datetime) -> Timezone:
        assert isinstance(dt.tzinfo, ZoneInfo)
        return cls(dt.tzinfo.key)

    def as_fzf_line_for_filtering_target_timezone(self, local_dt: datetime) -> str:
        dt = local_dt.astimezone(self.tzinfo)

        local_dt_utcoffset = local_dt.utcoffset()
        assert local_dt_utcoffset is not None
        dt_utcoffset = dt.utcoffset()
        assert dt_utcoffset is not None

        relative_offset = dt_utcoffset - local_dt_utcoffset

        return f"{self.name} {self.alpha2} {self.region_name_in_english} {dt.strftime('%Z')} {dt.strftime('UTC%z')} {format_timedelta(relative_offset)}"

    def as_alfred_item(self, local_dt: datetime) -> Dict:
        dt = local_dt.astimezone(self.tzinfo)

        local_dt_utcoffset = local_dt.utcoffset()
        assert local_dt_utcoffset is not None

        dt_utcoffset = dt.utcoffset()
        assert dt_utcoffset is not None

        relative_offset = dt_utcoffset - local_dt_utcoffset

        item = {
            "title": f"{self.name}, {self.alpha2}, {self.region_name_in_english}, {dt.strftime('%Z')}, {dt.strftime('UTC%z')} [{format_timedelta(relative_offset)} from Local]",
            "type": "default",
            "arg": self.name,
        }

        return item


timezones = [Timezone(name) for name in timezone_names]


def format_timedelta_without_sign(td: timedelta) -> str:
    hour = int(td.seconds / 3600)
    minute = int((td.seconds % 3600) / 60)
    if td.days >= 0:
        return f"{hour:0>2}{minute:0>2}"
    return f"{format_timedelta_without_sign(-td)}"


def format_timedelta(td: timedelta) -> str:
    if td.days >= 0:
        return f"+{format_timedelta_without_sign(td)}"
    return f"-{format_timedelta_without_sign(td)}"


def datetime_to_items(local_dt: datetime, query: str):
    out = []
    assert local_dt.tzinfo is not None

    if query == "":
        stdin = (
            Timezone.from_dt(local_dt).as_fzf_line_for_filtering_target_timezone(
                local_dt
            )
            + "\n"
        )
    else:
        stdin = "".join(
            [
                tz.as_fzf_line_for_filtering_target_timezone(local_dt) + "\n"
                for tz in timezones
            ]
        )

    try:
        proc = subprocess.run(
            [FZF, "--filter", query], input=stdin, text=True, capture_output=True
        )
        lines = [line.strip() for line in proc.stdout.split("\n") if line != ""]
        for line in lines:
            timezone = Timezone.restore_from_line(line)
            out.append(timezone.as_alfred_item(local_dt))
    except:
        pass

    return out


def main():
    query = sys.argv[1] if len(sys.argv) > 1 else ""
    print(
        json.dumps(
            {
                # Alfred show ⌘1 to ⌘9 only, so first 9 items are enough.
                "items": datetime_to_items(now_local, query)[:9],
            },
            ensure_ascii=False,
        )
    )


main()
