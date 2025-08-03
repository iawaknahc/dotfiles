#!/usr/bin/env python3

import argparse
import base64
import hashlib
import sys


class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main():
    parser = argparse.ArgumentParser(
        description="Generate SRI hash of stdin, and then print the result to stdout\nSee https://www.w3.org/TR/SRI/#integrity-metadata",
        formatter_class=Formatter,
    )

    parser.add_argument(
        "alg",
        help="Hash algorithm to use",
        choices=[
            "sha256",
            "sha384",
            "sha512",
        ],
    )

    args = parser.parse_args()
    alg: str = args.alg

    hash = hashlib.file_digest(sys.stdin.buffer, alg)
    bytes_ = hash.digest()
    encoded_bytes = base64.b64encode(bytes_)
    base64_str = encoded_bytes.decode()
    print(f"{alg}-{base64_str}")


if __name__ == "__main__":
    main()
