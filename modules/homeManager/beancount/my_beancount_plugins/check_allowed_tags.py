from typing import NamedTuple

from beancount import Directive, Meta
from beancount.core import data


class PluginError(NamedTuple):
    source: Meta
    message: str
    entry: Directive | None


def plugin(
    entries: list[Directive],
    _unused_options: dict[str, None] | None,
    config_str: str | None = None,
) -> tuple[list[Directive], list[PluginError]]:
    errors: list[PluginError] = []

    tag_set: set[str] = set()

    if config_str is not None:
        allowed_tags = config_str.split(" ")
        for tag in allowed_tags:
            if tag.startswith("#"):
                tag_set.add(tag[1:])

    for entry in entries:
        if isinstance(entry, data.Transaction):
            for tag in entry.tags:
                if tag not in tag_set:
                    errors.append(
                        PluginError(
                            source=entry.meta,
                            message=f'#{tag} is not an allowed tag. Allow it with `plugin "{__name__}" "#{tag}"`',
                            entry=entry,
                        )
                    )

    return entries, errors


__plugins__ = (plugin,)
