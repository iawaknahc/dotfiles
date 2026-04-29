#!/usr/bin/env python3

import argparse
import json
import os
import re
from dataclasses import dataclass
from pathlib import PurePath
from urllib.parse import (
    unquote_plus,
    urlsplit,
)

import requests


@dataclass
class Location:
    name: str
    url: str
    location: str
    coordinates: str
    tags: list[str]

    def json(self):
        return json.dumps(self.__dict__, ensure_ascii=False, indent=2)


def https_www_google_com_maps_place(url_str: str) -> Location:
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
    lat = match.group(1)
    lng = match.group(2)

    response = requests.post(
        "https://places.googleapis.com/v1/places:searchText",
        headers={
            "X-Goog-Api-Key": os.environ["GOOGLE_API_KEY"],
            "X-Goog-FieldMask": "places.id",
        },
        json={
            "textQuery": name,
            # Pass in a circle to eliminate alternatives in the results.
            "locationBias": {
                "circle": {
                    "center": {
                        "latitude": lat,
                        "longitude": lng,
                    },
                    "radius": 500,  # 500m
                },
            },
        },
    )

    body = response.json()
    if len(body["places"]) != 1:
        raise ValueError(f"expected single place: {body}")

    place_id = body["places"][0]["id"]
    response = requests.get(
        f"https://places.googleapis.com/v1/places/{place_id}?languageCode=zh-HK",
        headers={
            "X-Goog-Api-Key": os.environ["GOOGLE_API_KEY"],
            "X-Goog-FieldMask": "id,formattedAddress,types",
        },
    )
    body = response.json()

    return Location(
        name=name,
        url=u.geturl(),
        location=body["formattedAddress"],
        coordinates=f"{lat},{lng}",
        tags=body["types"],
    )


def main():
    parser = argparse.ArgumentParser(
        description="Invoke Google Places API (new) on the given Google Map URL, and output a JSON document with `name`, `url`, `location`, and `coordinates`.",
    )

    parser.add_argument(
        "url",
        help="The Google Map URL. It must start with `https://www.google.com/maps/place/`",
    )

    args = parser.parse_args()
    location = https_www_google_com_maps_place(args.url)
    print(location.json())


if __name__ == "__main__":
    main()
