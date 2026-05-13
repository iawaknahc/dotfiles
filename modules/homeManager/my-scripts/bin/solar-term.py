#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime, timedelta
from typing import cast
from zoneinfo import ZoneInfo

import numpy as np
from astropy.coordinates import (  # pyright: ignore[reportMissingTypeStubs]
    GeocentricTrueEcliptic,
    get_body,  # pyright: ignore[reportUnknownVariableType]
    solar_system_ephemeris,
)
from astropy.time import Time  # pyright: ignore[reportMissingTypeStubs]


class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def geocentric_true_ecliptic_lon_deg_of_sun(t: Time) -> np.float64:
    with solar_system_ephemeris.set("de432s"):  # pyright: ignore[reportUnknownMemberType]
        sun = get_body("sun", t)
        sun = sun.transform_to(GeocentricTrueEcliptic(equinox=t, obstime=t))  # pyright: ignore[reportUnknownMemberType]
        return sun.lon.deg  # pyright: ignore[reportReturnType, reportOptionalMemberAccess] # pyrefly: ignore[missing-attribute]


def find_solar_term(degree: float, year: int, zone_info: ZoneInfo) -> Time:
    start = Time(  # pyright: ignore[reportUnknownVariableType]
        datetime(year=year, month=1, day=1, tzinfo=zone_info),
        format="datetime",
        scale="utc",
    )
    end = Time(  # pyright: ignore[reportUnknownVariableType]
        datetime(year=year + 1, month=1, day=1, tzinfo=zone_info),
        format="datetime",
        scale="utc",
    )

    def get_mid() -> Time:
        jd_start = start.jd  # pyright: ignore[reportUnknownVariableType, reportUnknownMemberType]
        jd_end = end.jd  # pyright: ignore[reportUnknownVariableType, reportUnknownMemberType]
        return Time((jd_start + jd_end) / 2, format="jd", scale="utc")  # pyright: ignore[reportUnknownVariableType, reportOperatorIssue]

    def normalized_lon(t: Time) -> np.float64:
        lon = geocentric_true_ecliptic_lon_deg_of_sun(t)
        return (lon - degree + 180) % 360 - 180

    iteration = 0
    while iteration < 100:
        mid = get_mid()
        lon_mid = normalized_lon(mid)
        if np.abs(lon_mid) < 1e-6:
            return mid
        if lon_mid > 0:
            end = mid
        else:
            start = mid
        iteration += 1

    raise ValueError(f"failed to find solar term {degree} in {year}")


def valid_degree(s: str) -> int:
    v = int(s)
    if v % 15 != 0 or not (0 <= v <= 345):
        raise argparse.ArgumentTypeError(
            "degree must be a multiple of 15 in the range [0, 345]"
        )
    return v


# See https://github.com/astropy/astropy/issues/9603
MAX_YEAR = 2027


def valid_year(s: str) -> int:
    v = int(s)
    if not (1950 <= v <= MAX_YEAR):
        raise argparse.ArgumentTypeError(
            f"year must be in the range [1950, {MAX_YEAR}]"
        )
    return v


def round_to_minute(dt: datetime) -> datetime:
    return dt.replace(second=0, microsecond=0) + timedelta(minutes=dt.second // 30)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Find the date and time when the sun reaches a given ecliptic longitude",
        formatter_class=Formatter,
    )
    _ = parser.add_argument(
        "degree",
        help="Ecliptic longitude in degrees; must be a multiple of 15 in [0, 345]",
        type=valid_degree,
    )
    _ = parser.add_argument(
        "year",
        help=f"Year to search in; must be in [1950, {MAX_YEAR}]",
        type=valid_year,
    )
    args = parser.parse_args()
    degree = cast(int, args.degree)
    year = cast(int, args.year)

    zone_info = ZoneInfo("Asia/Hong_Kong")
    t = find_solar_term(degree, year, zone_info)
    dt = cast(datetime, t.to_datetime(timezone=zone_info))  # pyright: ignore[reportUnknownMemberType]
    # The result is accurate to nearest minute.
    dt = round_to_minute(dt)
    print(dt.isoformat())


if __name__ == "__main__":
    main()
