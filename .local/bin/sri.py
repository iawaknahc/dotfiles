#!/usr/bin/env python3

import argparse
import base64
import hashlib
import sys


class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


ALGORITHMS = [
    "sha256",
    "sha384",
    "sha512",
]


def main():
    parser = argparse.ArgumentParser(
        description="Generate SRI hash of stdin, and then print the result to stdout\nSee https://www.w3.org/TR/SRI/#integrity-metadata",
        formatter_class=Formatter,
    )

    parser.add_argument(
        "alg",
        help="Hash algorithm to use",
        choices=ALGORITHMS,
    )

    args = parser.parse_args()
    alg: str = args.alg

    buf = bytearray(2**18)
    view = memoryview(buf)
    hash = hashlib.new(alg)
    while True:
        size = sys.stdin.buffer.readinto(buf)
        if size == 0:
            break
        hash.update(view[:size])
    bytes_ = hash.digest()
    encoded_bytes = base64.b64encode(bytes_)
    base64_str = encoded_bytes.decode()
    print(f"{alg}-{base64_str}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        # The internet says 130 is a common exit code when the program
        # was terminated with CTRL-C.
        sys.exit(130)
    except BrokenPipeError as exc:
        sys.exit(exc.errno)
