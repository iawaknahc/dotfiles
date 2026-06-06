---
name: beancount-create-plugin
description: Creates a new Beancount plugin as a Python file. Use when the user asks to write, scaffold, or add a Beancount plugin.
when_to_use: Trigger phrases — "create a beancount plugin", "write a plugin for beancount", "add a plugin", "new beancount plugin".
user-invocable: true
---

# Skill: Create a Beancount Plug-in

Create a new Beancount plug-in as a Python file in the working directory the agent is running.

## Steps

1. **Ask** the user for:
   - The plugin filename (e.g. `plugin.py`)

2. **Create** the plugin file using the skeleton below.

## Skeleton

```python
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
    return entries, errors


__plugins__ = (plugin,)
```

## Key conventions

- **`PluginError`** is a `NamedTuple` with three fields:
  - `source: Meta` — metadata dict pointing to where the error originates; use `entry.meta` for the offending entry, or `beancount.core.data.new_metadata('<filename>', 0)` for synthetic errors.
  - `message: str` — human-readable error description.
  - `entry: Transaction | None` — the offending directive, or `None` if not applicable.

- **`plugin(entries, options)`** receives the full list of parsed directives and must return `(entries, errors)`. You may:
  - **Filter** entries by removing items from the list.
  - **Modify** entries by replacing items (directives are immutable `NamedTuple`s; use `entry._replace(...)` to produce a modified copy).
  - **Inject** new entries by appending to the list.
  - **Accumulate** errors without altering entries when you only want to warn.

- **`__plugins__`** is a module-level tuple that Beancount uses to discover plugin entry points. Always include it.

- Rename `_unused_options` to `options` if the plugin reads plug-in arguments from the beancount file (e.g. `plugin "plugin" "arg"`).

## Common directive types (from `beancount.core.data`)

| Type | Description |
|------|-------------|
| `Transaction` | A transaction with postings |
| `Open` | Account open directive |
| `Close` | Account close directive |
| `Balance` | Balance assertion |
| `Pad` | Padding directive |
| `Note` | Freeform note |
| `Document` | Attached document |
| `Price` | Price entry |
| `Event` | Named event |
| `Custom` | Custom user-defined directive |

Filter by type with `isinstance(entry, Transaction)`.

## Referencing the plugin in a `.beancount` file

```beancount
plugin "plugin"
; or, with an argument string:
plugin "plugin" "some-argument"
```

The plugin file must be importable (i.e. on `PYTHONPATH`).
How to make the plugin file importable is out of the scope of this skill.
