from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
import logging
import json
import os
import subprocess
import sys
from typing import Dict
from zoneinfo import ZoneInfo

import pytz
import tzlocal
from parsy import string, regex, generate, ParseError


FZF = os.environ.get("FZF", "fzf")


logging.basicConfig(stream=sys.stderr, level=logging.INFO)
logger = logging.getLogger("t.py")


local_timezone = tzlocal.get_localzone()
if not isinstance(local_timezone, ZoneInfo):
    raise ValueError("This script can only work with ZoneInfo")


now_local = datetime.now().astimezone(local_timezone)


timezone_names = list(pytz.common_timezones)


@dataclass
class Timezone:
    name: str
    tzinfo: ZoneInfo

    def __init__(self, name: str):
        self.name = name
        self.tzinfo = ZoneInfo(name)

    @classmethod
    def restore_from_line(cls, line: str) -> Timezone:
        parts = line.split(" ")
        name = parts[0]
        return cls(name)

    @classmethod
    def from_dt(cls, dt: datetime) -> Timezone:
        assert isinstance(dt.tzinfo, ZoneInfo)
        return cls(dt.tzinfo.key)

    def as_fzf_line_for_filtering_source_timezone(self, ref: datetime) -> str:
        ref = ref.astimezone(self.tzinfo)
        z_ = ref.strftime("UTC%z")
        Z_ = ref.strftime("%Z")
        return f"{self.name} {z_} {Z_}"

    def as_fzf_line_for_filtering_target_timezone(self, source_dt: datetime) -> str:
        target_dt = source_dt.astimezone(self.tzinfo)

        source_utcoffset = source_dt.utcoffset()
        assert source_utcoffset is not None
        target_utcoffset = target_dt.utcoffset()
        assert target_utcoffset is not None

        relative_offset = target_utcoffset - source_utcoffset
        formatted_offset = format_timedelta(relative_offset)

        z_ = target_dt.strftime("UTC%z")
        Z_ = target_dt.strftime("%Z")

        return f"{self.name} {z_} {Z_} {formatted_offset}"

    def as_alfred_item(self, dt: datetime) -> Dict:
        that_dt = dt.astimezone(self.tzinfo)

        is_source = dt.tzinfo == self.tzinfo

        dt_date = dt.date()
        that_date = that_dt.date()
        is_prev = that_date < dt_date
        is_next = that_date > dt_date

        dt_utcoffset = dt.utcoffset()
        assert dt_utcoffset is not None

        that_utcoffset = that_dt.utcoffset()
        assert that_utcoffset is not None

        relative_offset = that_utcoffset - dt_utcoffset

        subtitle_parts = []
        if is_source:
            subtitle_parts.append("Source")

        if is_prev:
            subtitle_parts.append("Yesterday")
        elif is_next:
            subtitle_parts.append("Tomorrow")
        else:
            subtitle_parts.append("Today")

        item = {
            "title": f"{that_dt.strftime("%H:%M [UTC%z, %Z,")} {self.name}] [{format_timedelta(relative_offset)} from Source]",
            "subtitle": ", ".join(subtitle_parts),
            "type": "default",
            "arg": that_dt.strftime("%H:%M"),
        }

        return item


timezones = [Timezone(name) for name in timezone_names]


def find_timezone_for_source_z(dt: datetime, source_z: str) -> Timezone|None:
    stdin = "".join([tz.as_fzf_line_for_filtering_source_timezone(dt) + "\n" for tz in timezones])

    try:
        proc = subprocess.run(
            [FZF, "--filter", source_z],
            input=stdin,
            text=True,
            capture_output=True
        )
        lines = [line.strip() for line in proc.stdout.split("\n") if line != ""]
        if len(lines) > 0:
            return Timezone.restore_from_line(lines[0])
    except:
        return None


hour = (regex(r"[0-1]\d") | regex(r"2[0-3]") | regex(r"\d")).map(int)
minute = (regex(r"[0-5]\d") | regex(r"\d")).map(int)
colon = string(":")
zero_or_more_whitespace = regex(r"\s*")
am = string("am", transform=lambda s: s.lower())
pm = string("pm", transform=lambda s: s.lower())
timezone_hint = regex(r"[-+a-zA-Z][-+a-zA-Z0-9_/]*")


@dataclass
class Input:
    hour: int|None
    minute: int|None
    source: str|None
    target: str|None

    def apply(self, dt: datetime) -> datetime:
        if self.hour is not None:
            dt = dt.replace(hour=self.hour)
        if self.minute is not None:
            dt = dt.replace(minute=self.minute)
        if self.source is not None:
            timezone = find_timezone_for_source_z(dt, self.source)
            if timezone is not None:
                logger.info("source_z %r -> %r", self.source, timezone.name)
                dt = dt.replace(tzinfo=timezone.tzinfo)
        return dt


@generate
def parser():
    yield zero_or_more_whitespace
    h = yield hour.optional()

    yield zero_or_more_whitespace
    yield colon.optional()

    yield zero_or_more_whitespace
    m = yield minute.optional()

    yield zero_or_more_whitespace
    ampm = yield (am | pm).optional()

    yield zero_or_more_whitespace
    source = yield timezone_hint.optional()

    yield zero_or_more_whitespace
    target = yield timezone_hint.optional()

    # Consume trailing whitespaces.
    yield zero_or_more_whitespace

    if ampm is not None and h is not None:
        if ampm == "pm" and h >= 1 and h <= 11:
            h += 12

    return Input(hour=h, minute=m, source=source, target=target)


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


def datetime_to_items(dt: datetime, target_z: str|None):
    out = []

    assert dt.tzinfo is not None
    dt_timezone = Timezone.from_dt(dt)

    # Always show the source first to give context.
    out.append(dt_timezone.as_alfred_item(dt))

    stdin = "".join([tz.as_fzf_line_for_filtering_target_timezone(dt) + "\n" for tz in timezones if tz.tzinfo != dt_timezone.tzinfo])

    query = "" if target_z is None else target_z
    try:
        proc = subprocess.run(
            [FZF, "--filter", query],
            input=stdin,
            text=True,
            capture_output=True
        )
        lines = [line.strip() for line in proc.stdout.split("\n") if line != ""]
        for line in lines:
            timezone = Timezone.restore_from_line(line)
            out.append(timezone.as_alfred_item(dt))
    except:
        pass

    return out


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1]

    logger.info("arg %r", arg)
    try:
        input: Input = parser.parse(arg)
        logger.info("parsed %r", input)
    except ParseError:
        print(json.dumps({
            "items": [{
                "title": "Invalid syntax",
                "type": "default",
                "valid": False,
            }]
        }, ensure_ascii=False))
        sys.exit(1)

    dt = input.apply(now_local)

    print(json.dumps({
        # Alfred show ⌘1 to ⌘9 only, so first 9 items are enough.
        "items": datetime_to_items(dt, input.target)[:9],
    }, ensure_ascii=False))


main()
