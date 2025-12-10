import json
from datetime import datetime, timezone
from email.utils import formatdate


def main():
    now = datetime.now().astimezone()
    now_utc = now.astimezone(timezone.utc)

    iso_year, iso_week_num, iso_weekday = now.isocalendar()
    iso_week_date = f"{iso_year}-W{iso_week_num:02d}-{iso_weekday}"

    http_date = formatdate(timeval=now_utc.timestamp(), localtime=False, usegmt=True)

    items = [
        {
            "title": now.date().isoformat(),
            "subtitle": "YYYY-MM-dd",
            "type": "default",
            "arg": now.date().isoformat(),
        },
        {
            "title": now.replace(tzinfo=None).isoformat(timespec="seconds"),
            "subtitle": "Local datetime without offset",
            "type": "default",
            "arg": now.replace(tzinfo=None).isoformat(timespec="seconds"),
        },
        {
            "title": iso_week_date,
            "subtitle": "ISO week date",
            "type": "default",
            "arg": iso_week_date,
        },
        {
            "title": http_date,
            "subtitle": "HTTP date",
            "type": "default",
            "arg": http_date,
        },
    ]

    print(json.dumps({"items": items}, ensure_ascii=False))


main()
