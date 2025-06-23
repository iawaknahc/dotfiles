#!/usr/bin/env python3

import argparse
from urllib.parse import quote, quote_plus, unquote, unquote_plus


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
        help="The string to be encoded or decoded",
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

    for input in args.input:
        if operation == "encode":
            if position == "query":
                print(quote_plus(input, safe=safe))
            else:
                print(quote(input, safe=safe))
        elif operation == "decode":
            if position == "query":
                print(unquote_plus(input))
            else:
                print(unquote(input))
        else:
            raise Exception("unreachable")


if __name__ == "__main__":
    main()
