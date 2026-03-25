#!/usr/bin/env python3

import argparse
import os
import sys
from urllib.parse import quote_from_bytes, unquote_to_bytes


# ArgumentDefaultsHelpFormatter prints default=None even I did not specify it.
# default=argparse.SUPPRESS suppresses this behavior.
# The side effect of default=argparse.SUPPRESS is that if the option is unspecified,
# then the attribute is not present.
# This implies we need to use hasattr to check if the flag was specified.
class Formatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main():
    parser = argparse.ArgumentParser(
        description="Percent encoding utility",
        formatter_class=Formatter,
    )

    g1 = parser.add_mutually_exclusive_group()
    g1.add_argument(
        "-e",
        "--encode",
        help="Encode",
        action="store_true",
        default=True,
    )
    g1.add_argument(
        "-d",
        "--decode",
        help="Decode",
        action="store_true",
        default=argparse.SUPPRESS,
    )

    g2 = parser.add_mutually_exclusive_group()
    g2.add_argument(
        "-u",
        "--unspecified",
        help="Encode non-unreserved characters\nhttps://datatracker.ietf.org/doc/html/rfc3986#section-2.3",
        action="store_true",
        default=True,
    )
    g2.add_argument(
        "-p",
        "--path",
        help="Encode path component\nhttps://datatracker.ietf.org/doc/html/rfc3986#section-3.3",
        action="store_true",
        default=argparse.SUPPRESS,
    )
    g2.add_argument(
        "-q",
        "--query",
        help="Encode x-www-form-urlencoded\nhttps://url.spec.whatwg.org/#application/x-www-form-urlencoded",
        action="store_true",
        default=argparse.SUPPRESS,
    )
    g2.add_argument(
        "-f",
        "--fragment",
        help="Encode fragment\nhttps://datatracker.ietf.org/doc/html/rfc3986#section-3.5",
        action="store_true",
        default=argparse.SUPPRESS,
    )

    parser.add_argument(
        "input",
        help="The string or byte sequence to be encoded or decoded",
        nargs="+",
    )

    args = parser.parse_args()

    operation = "encode"
    if hasattr(args, "decode"):
        operation = "decode"

    position = "unspecified"
    if hasattr(args, "path"):
        position = "path"
    elif hasattr(args, "query"):
        position = "query"
    elif hasattr(args, "fragment"):
        position = "fragment"

    safe = ""
    if position == "path":
        # RFC3986 3.3
        # pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
        safe = "!$&'()*+,;=" + ":@"
    elif position == "query":
        # RFC3986 3.4
        # query       = *( pchar / "/" / "?" )
        # https://url.spec.whatwg.org/#urlencoded-parsing
        # & and = is not safe
        safe = "!$'()*+,;" + ":@" + "/?"
    elif position == "fragment":
        # RFC3986 3.5
        # fragment    = *( pchar / '/' / '?' )
        safe = "!$&'()*+,;=" + ":@" + "/?"

    for string_or_byte_sequence_as_str in args.input:
        # According to https://docs.python.org/3/library/sys.html#sys.argv
        # os.fsencode(arg) is the official way to access the original bytes of the arguments.
        byte_sequence = os.fsencode(string_or_byte_sequence_as_str)
        if operation == "encode":
            if position == "query":
                # quote_from_bytes returns str, so we can just print() it.
                print(
                    quote_from_bytes(byte_sequence, safe=safe.encode() + b" ").replace(
                        " ", "+"
                    )
                )
            else:
                # quote_from_bytes returns str, so we can just print() it.
                print(quote_from_bytes(byte_sequence, safe=safe))
        elif operation == "decode":
            if position == "query":
                # unquote_to_bytes returns bytes, so we need a binary stream to write it.
                sys.stdout.buffer.write(
                    unquote_to_bytes(byte_sequence.replace(b"+", b" "))
                )
                # write() is low-level so we need to print the newline ourselves.
                sys.stdout.buffer.write(b"\n")
            else:
                # unquote_to_bytes returns bytes, so we need a binary stream to write it.
                sys.stdout.buffer.write(unquote_to_bytes(byte_sequence))
                # write() is low-level so we need to print the newline ourselves.
                sys.stdout.buffer.write(b"\n")
        else:
            raise Exception("unreachable")


if __name__ == "__main__":
    main()
