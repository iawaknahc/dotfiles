from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
import logging
import json
import os
import re
import subprocess
import sys
from typing import Dict
from zoneinfo import ZoneInfo

import pytz
import tzlocal


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
        z_ = ref.strftime("%z")
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

        z_ = target_dt.strftime("%z")
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
            "title": f"{that_dt.strftime("%H:%M [%z, %Z,")} {self.name}] [{format_timedelta(relative_offset)} from Source]",
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


def parse_arg(arg: str):
    hour = None
    minute = None
    ampm = None
    source_z = None
    target_z = None

    parts = re.split("[ :.]+", arg)
    parts = [p for p in parts if p != ""]

    for part in parts:
        try:
            int_ = int(part)
            if hour is None:
                hour = min(23, max(0, int_))
                continue
            elif minute is None:
                minute = min(59, max(0, int_))
                continue
        except ValueError:
            pass
        part = part.lower()
        if ampm is None and part in ["am", "pm"]:
            ampm = part
        elif source_z is None:
            source_z = part
        elif target_z is None:
            target_z = part

    # Special case
    if hour is None and minute is None and source_z is not None and target_z is None:
        target_z = source_z
        source_z = None

    # Handle ampm
    if ampm is not None and hour is not None:
        if ampm == "pm" and hour >= 1 and hour <= 11:
            hour += 12

    return {
        "hour": hour,
        "minute": minute,
        "ampm": ampm,
        "source_z": source_z,
        "target_z": target_z,
    }


def format_timedelta_without_sign(td: timedelta) -> str:
    hour = int(td.seconds / 3600)
    minute = int((td.seconds % 3600) / 60)
    if td.days >= 0:
        return f"{hour:0>2}:{minute:0>2}"
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


def apply_parsed(parsed, dt: datetime):
    if parsed["hour"] is not None:
        dt = dt.replace(hour=parsed["hour"])

    if parsed["minute"] is not None:
        dt = dt.replace(minute=parsed["minute"])

    if parsed["source_z"] is not None:
        timezone = find_timezone_for_source_z(dt, parsed["source_z"])
        if timezone is not None:
            logger.info("source_z %r -> %r", parsed["source_z"], timezone.name)
            dt = dt.replace(tzinfo=timezone.tzinfo)
    return dt


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()

    logger.info("arg %r", arg)
    parsed = parse_arg(arg)
    logger.info("parsed %r", parsed)

    dt = apply_parsed(parsed, now_local)

    print(json.dumps({
        "items": datetime_to_items(dt, parsed["target_z"]),
    }, ensure_ascii=False))


main()
