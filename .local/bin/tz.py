#!/usr/bin/env python3

import sys
import zoneinfo

import tzlocal

try:
    tzinfo = tzlocal.get_localzone()
    print(tzinfo.key)
except zoneinfo.ZoneInfoNotFoundError:
    sys.exit(1)
