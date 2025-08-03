#!/usr/bin/env python3

# Here are the reasons to write this Python program.
# 1. The date command that comes with macOS is based on strptime and strftime, which does not handle RFC3339 natively.
# 2. The datetime class of Python is also based on strptime and strftime, so it does not handle RFC3339 natively neither.
# 3. Ruby seems to have native support for RFC3339. But as of 2024-11-16, the ruby that comes with macOS says it will
#    be removed in a future version of macOS, so a Ruby script may not run on a future version of macOS.
# 4. Python seems to stay around on macOS for a foreseeable future.
# 5. I know how to program in Python.

import argparse
import re
from datetime import datetime, timedelta, timezone, tzinfo
from typing import Optional
from zoneinfo import ZoneInfo

RE_RFC3339 = re.compile(
    r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?)(Z|[+-]\d{2}:\d{2})$"
)


class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


FORMATS = [
    "unix_s",
    "unix_ms",
    "rfc3339",
    "http",
]


def abs_delta(d: timedelta) -> timedelta:
    if d < timedelta():
        return +d
    return d


def guess_from(input: str) -> tuple[str, datetime]:
    match = RE_RFC3339.match(input)
    if match is not None:
        return ("rfc3339", parse_input("rfc3339", input))
    try:
        # If this does not raise, then input looks like an integer.
        _ = int(input)
    except ValueError:
        return ("http", parse_input("http", input))

    dt_assuming_ms = parse_input("unix_ms", input)
    try:
        # If this raises, then input is too big to be assumed as unix seconds.
        dt_assuming_s = parse_input("unix_s", input)
    except ValueError:
        return ("unix_ms", dt_assuming_ms)

    now = datetime.now(timezone.utc).astimezone()

    timedelta_assuming_s = abs_delta(now - dt_assuming_s)
    timedelta_assuming_ms = abs_delta(now - dt_assuming_ms)
    if timedelta_assuming_s < timedelta_assuming_ms:
        return ("unix_s", dt_assuming_s)
    return ("unix_ms", dt_assuming_ms)


def parse_input(format: str, input: str) -> datetime:
    local = datetime.now(timezone.utc).astimezone().tzinfo
    assert local is not None
    if format == "unix_s":
        return datetime.fromtimestamp(int(input), local)
    elif format == "unix_ms":
        ms = int(input)
        return datetime.fromtimestamp(ms // 1000, local) + timedelta(
            milliseconds=ms % 1000
        )
    elif format == "rfc3339":
        match = RE_RFC3339.match(input)
        if match is None:
            raise ValueError("input does not conform to RFC3339")

        without_time_offset = match.group(1)
        time_offset = match.group(2)
        # %z does not accept colon.
        time_offset = time_offset.replace(":", "")
        input = without_time_offset + time_offset

        try:
            dt = datetime.strptime(input, "%Y-%m-%dT%H:%M:%S.%f%z")
        except ValueError:
            dt = datetime.strptime(input, "%Y-%m-%dT%H:%M:%S%z")
        return dt.astimezone(local)
    elif format == "http":
        naive = datetime.strptime(input, "%a, %d %b %Y %H:%M:%S GMT")
        aware = naive.replace(tzinfo=timezone.utc)
        return aware.astimezone(local)
    else:
        raise TypeError("unreachable")


def format_secfrac(microseconds: int) -> str:
    if microseconds == 0:
        return ""
    if (microseconds % 1000) == 0:
        return "." + str(microseconds // 1000)
    return "." + str(microseconds)


def format_time_offset(delta: timedelta) -> str:
    if delta == timedelta():
        return "Z"

    sign = "+"
    if delta < timedelta():
        sign = "-"
        delta = +delta

    hours = delta // timedelta(hours=1)
    delta = delta - timedelta(hours=hours)
    minutes = delta // timedelta(minutes=1)

    time_offset = "{}{:02d}:{:02d}".format(sign, hours, minutes)
    return time_offset


def format_datetime(format: str, dt: datetime) -> str:
    if format == "unix_s":
        return str(int(dt.timestamp() // 1))
    elif format == "unix_ms":
        return str(int((dt.timestamp() * 1000) // 1))
    elif format == "rfc3339":
        up_to_seconds = dt.strftime("%Y-%m-%dT%H:%M:%S")

        secfrac = format_secfrac(dt.microsecond)

        delta = dt.utcoffset()
        assert delta is not None
        time_offset = format_time_offset(delta)

        return up_to_seconds + secfrac + time_offset
    elif format == "http":
        gmt = dt.astimezone(timezone.utc)
        return gmt.strftime("%a, %d %b %Y %H:%M:%S GMT")
    else:
        raise TypeError("unreachable")


def parse_timezone(tzname: Optional[str]) -> Optional[tzinfo]:
    if tzname is None:
        return None
    return ZoneInfo(tzname)


def main():
    parser = argparse.ArgumentParser(
        description="Convert between common datetime formats",
        formatter_class=Formatter,
    )

    parser.add_argument(
        "--tz",
        help="Output timezone, for example, Asia/Hong_Kong. If not given, the system timezone is used.",
    )
    parser.add_argument(
        "--from",
        help="From format. If not given, it is guessed from input.",
        choices=FORMATS,
    )
    parser.add_argument(
        "--to",
        help="To format. If not given, it is equal to --from.",
        choices=FORMATS,
    )
    parser.add_argument(
        "input",
        help="Input",
        nargs=1,
    )

    args = parser.parse_args()
    tzname: Optional[str] = args.tz
    from_: Optional[str] = getattr(args, "from")
    to: Optional[str] = args.to

    input: str = args.input[0]
    input = input.strip()

    if from_ is None:
        (from_, dt) = guess_from(input)
    else:
        dt = parse_input(from_, input)

    if to is None:
        to = from_

    tz = parse_timezone(tzname)
    if tz is not None:
        dt = dt.astimezone(tz)

    out = format_datetime(to, dt)
    print(out)


if __name__ == "__main__":
    main()
