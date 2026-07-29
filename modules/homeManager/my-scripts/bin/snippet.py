#!/usr/bin/env python3
import argparse
import datetime


def today() -> str:
    return datetime.date.today().isoformat()


def yesterday() -> str:
    d = datetime.date.today() + datetime.timedelta(days=-1)
    return d.isoformat()


def tomorrow() -> str:
    d = datetime.date.today() + datetime.timedelta(days=1)
    return d.isoformat()


def thisweek() -> str:
    return datetime.date.today().strftime("%G-W%V")


def lastweek() -> str:
    d = datetime.date.today() + datetime.timedelta(weeks=-1)
    return d.strftime("%G-W%V")


def nextweek() -> str:
    d = datetime.date.today() + datetime.timedelta(weeks=1)
    return d.strftime("%G-W%V")


COMMANDS = [today, yesterday, tomorrow, thisweek, lastweek, nextweek]


def main():
    parser = argparse.ArgumentParser(description="Snippet helper for Neovim and Emacs")
    sub_parsers = parser.add_subparsers(required=True)
    for command in COMMANDS:
        sub = sub_parsers.add_parser(command.__name__)
        sub.set_defaults(func=command)

    args = parser.parse_args()
    print(args.func())


if __name__ == "__main__":
    main()
