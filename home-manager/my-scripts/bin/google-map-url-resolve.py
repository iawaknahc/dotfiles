#!/usr/bin/env python3

import argparse
import re
from pathlib import PurePath
from urllib.parse import (
    quote_plus,
    unquote_plus,
    urlencode,
    urlsplit,
)

import requests


def https_maps_app_goo_gl(url_str: str) -> str:
    parsed_url = urlsplit(url_str)
    if parsed_url.scheme == "https" and parsed_url.hostname == "maps.app.goo.gl":
        response = requests.get(url_str, allow_redirects=False)
        return response.headers["Location"]
    return url_str


def https_www_google_com_maps_place(url_str: str) -> str:
    u = urlsplit(url_str)
    if u.scheme != "https":
        raise ValueError(f"expected scheme to `https`: {url_str}")
    if u.hostname != "www.google.com":
        raise ValueError(f"expected hostname to be `www.google.com`: {url_str}")
    if not u.path.startswith("/maps/place/"):
        raise ValueError(f"expected path to start with `/maps/place/`: {url_str}")
    p = PurePath(u.path)
    # 0   1      2       3
    # "/" "maps" "place" name
    name = unquote_plus(p.parts[3])
    data = None
    for part in p.parts:
        if part.startswith("data="):
            data = part
    if data is None:
        raise ValueError(f"expected a path component to start with `data=`: {url_str}")
    match = re.search(r"!3d(\d+\.\d+)!4d(\d+\.\d+)", data)
    if match is None:
        raise ValueError(f"expected data to contains !3d and !4d: {url_str}")

    query = urlencode({"hl": "zh-HK"})
    path = str(PurePath("/", "maps", "place", quote_plus(name), data))
    return u._replace(path=path, query=query, fragment="").geturl()


def main():
    parser = argparse.ArgumentParser(
        description="Resolve a Google Map URL to a JSON document with `name`, `url`, and `coordinates`.",
    )

    parser.add_argument(
        "url",
        help="The Google Map URL",
    )

    args = parser.parse_args()

    url_str = https_maps_app_goo_gl(args.url)
    url_str = https_www_google_com_maps_place(url_str)
    print(url_str)


if __name__ == "__main__":
    main()
