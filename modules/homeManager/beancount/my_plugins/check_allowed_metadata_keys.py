from typing import NamedTuple

from beancount import Directive, Meta
from beancount.core import data

BUILTIN_KEYS: frozenset[str] = frozenset(
    {
        # filename is a builtin metadata key.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/data.py#L517
        "filename",
        # lineno is a builtin metadata key.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/data.py#L517
        "lineno",
        # __tolerances__ stores the tolerances of the amount.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L214
        "__tolerances__",
        # `"__automatic__": True` means the amount of the posting is inferred.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L208
        "__automatic__",
        # `"__residual__": True` means the posting was inserted to handle rounding error.
        # See https://github.com/beancount/beancount/blob/v3/beancount/core/interpolate.py#L211
        "__residual__",
    }
)


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

    allowed_keys: set[str] = set()
    allowed_keys |= BUILTIN_KEYS
    if config_str is not None:
        allowed_keys |= set(config_str.split(" "))

    for entry in entries:
        for key in entry.meta:
            if key not in allowed_keys:
                errors.append(
                    PluginError(
                        source=entry.meta,
                        message=f'"{key}" is not an allowed metadata key. Allow it with `plugin "{__name__}" "{key}"`',
                        entry=entry,
                    )
                )
        if isinstance(entry, data.Transaction):
            for posting in entry.postings:
                if posting.meta is not None:
                    for key in posting.meta:
                        if key not in allowed_keys:
                            errors.append(
                                PluginError(
                                    source=posting.meta,
                                    message=f'"{key}" is not an allowed metadata key. Allow it with `plugin "{__name__}" "{key}"`',
                                    entry=entry,
                                )
                            )

    return entries, errors


__plugins__ = (plugin,)
