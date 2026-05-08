#!/usr/bin/env python3

from __future__ import annotations

import argparse
import base64
import hashlib
import sys
from io import BufferedIOBase
from typing import Literal, cast

Algorithm = Literal["sha256", "sha384", "sha512"]


class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate SRI hash of stdin, and then print the result to stdout\nSee https://www.w3.org/TR/SRI/#integrity-metadata",
        formatter_class=Formatter,
    )
    _ = parser.add_argument(
        "alg", help="Hash algorithm to use", choices=["sha256", "sha384", "sha512"]
    )
    args = parser.parse_args()
    alg = cast(Algorithm, args.alg)
    if not isinstance(sys.stdin.buffer, BufferedIOBase):
        raise TypeError("expected sys.stdin.buffer to be an instance of BufferedIOBase")
    digest = hashlib.file_digest(sys.stdin.buffer, alg).digest()
    print(f"{alg}-{base64.b64encode(digest).decode()}")


if __name__ == "__main__":
    main()
