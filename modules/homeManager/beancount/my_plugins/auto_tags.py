from typing import NamedTuple

from beancount.core import data


class PluginError(NamedTuple):
    source: data.Meta
    message: str
    entry: data.Directive | None


def plugin(
    entries: list[data.Directive],
    _unused_options: dict[str, None] | None,
    _config_str: str | None = None,
) -> tuple[list[data.Directive], list[PluginError]]:
    errors: list[PluginError] = []

    # First, see what account has opted in this plugin.
    account_tags: dict[data.Account, frozenset[str]] = {}
    for entry in entries:
        if isinstance(entry, data.Open):
            if "auto_tags" in entry.meta:
                try:
                    tags_: set[str] = set()
                    tags_str = entry.meta["auto_tags"]  # pyright: ignore[reportAny]
                    if not isinstance(tags_str, str):
                        raise ValueError()

                    for tag in tags_str.split(" "):
                        if not tag.startswith("#"):
                            raise ValueError()
                        tags_.add(tag[1:])

                    account_tags[entry.account] = frozenset(tags_)
                except ValueError:
                    errors.append(
                        PluginError(
                            source=entry.meta,
                            message='`auto_tags` must be a string containing space-separated tags, for example "#a #b"',
                            entry=entry,
                        )
                    )

    for idx, entry in enumerate(entries):
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if posting.account in account_tags:
                    entries[idx] = entry._replace(
                        tags=entry.tags | account_tags[posting.account]
                    )

    return entries, errors


__plugins__ = (plugin,)
