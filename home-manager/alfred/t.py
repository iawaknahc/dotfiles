import sys
import json
import re
from datetime import datetime, tzinfo, timedelta
from zoneinfo import ZoneInfo

import pytz
import tzlocal


local_timezone = tzlocal.get_localzone()
if not isinstance(local_timezone, ZoneInfo):
    raise ValueError("This script can only work with ZoneInfo")


now_local = datetime.now().astimezone(local_timezone)


timezone_names = list(pytz.common_timezones)


timezones = []
for name in timezone_names:
    zoneinfo = ZoneInfo(name)
    that_dt = now_local.astimezone(zoneinfo)
    timezones.append({
        "name": name,
        "%z": that_dt.strftime("%z"),
        "%Z": that_dt.strftime("%Z"),
        "tzinfo": zoneinfo,
    })


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


def match_timezone(z: str, timezone):
    z = z.lower()

    if z in timezone["name"].replace("_", "").lower():
        return True
    elif z in timezone["%z"].lower():
        return True
    elif z in timezone["%Z"].lower():
        return True

    return False


def find_timezone_longest_match(z: str):
    found = None
    z = z.lower()
    matched_length = 0
    for timezone in timezones:
        if z in timezone["name"].replace("_", "").lower() and len(timezone["name"]) > matched_length:
            matched_length = len(timezone["name"])
            found = timezone
        elif z in timezone["%z"].lower() and len(timezone["%z"]) > matched_length:
            matched_length = len(timezone["%z"])
            found = timezone
        elif z in timezone["%Z"].lower() and len(timezone["%Z"]) > matched_length:
            matched_length = len(timezone["%Z"])
            found = timezone
    return found


def find_timezone_by_tzinfo(tzinfo_: tzinfo):
    for timezone in timezones:
        if timezone["tzinfo"] == tzinfo_:
            return timezone

    raise TypeError("unreacable")


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


def datetime_to_item(dt: datetime, timezone):
    that_dt = dt.astimezone(timezone["tzinfo"])

    is_source = dt.tzinfo == timezone["tzinfo"]

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
        "title": f"{that_dt.strftime("%H:%M [%z, %Z,")} {timezone["name"]}] [{format_timedelta(relative_offset)} from Source]",
        "subtitle": ", ".join(subtitle_parts),
        "type": "default",
        "arg": that_dt.strftime("%H:%M"),
    }

    return item


def datetime_to_items(dt: datetime, target_z: str|None):
    out = []

    assert dt.tzinfo is not None
    dt_timezone = find_timezone_by_tzinfo(dt.tzinfo)

    # Always show the source first to give context.
    out.append(datetime_to_item(dt, dt_timezone))

    for timezone in timezones:
        if timezone["tzinfo"] != dt_timezone["tzinfo"]:
            if target_z is not None:
                if match_timezone(target_z, timezone):
                    out.append(datetime_to_item(dt, timezone))
            else:
                out.append(datetime_to_item(dt, timezone))

    return out


def apply_parsed(parsed, dt: datetime):
    if parsed["hour"] is not None:
        dt = dt.replace(hour=parsed["hour"])
    if parsed["minute"] is not None:
        dt = dt.replace(minute=parsed["minute"])
    if parsed["source_z"] is not None:
        timezone = find_timezone_longest_match(parsed["source_z"])
        if timezone is not None:
            dt = dt.replace(tzinfo=timezone["tzinfo"])
    return dt


def main():
    arg = ""
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()

    parsed = parse_arg(arg)

    dt = apply_parsed(parsed, now_local)

    print(json.dumps({
        "items": datetime_to_items(dt, parsed["target_z"]),
    }, ensure_ascii=False))


main()
