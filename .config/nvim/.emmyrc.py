#!/usr/bin/env python3
import json
import pathlib

import tomllib


def main():
    out = []
    with open(".config/nvim/.emmyrc.toml", "rb") as f:
        d = tomllib.load(f)
        library = d["workspace"]["library"]

        p_str: str
        for p_str in library:
            is_ftplugin_vim = p_str.endswith("/ftplugin.vim")
            is_ended_with_slash = p_str.endswith("/")
            a = pathlib.Path(p_str).expanduser().resolve()
            if is_ftplugin_vim:
                out.append(str(a.parent))
            if is_ended_with_slash:
                for p_child in a.iterdir():
                    a_child = p_child.resolve()
                    out.append(str(a_child))

    d["workspace"]["library"] = out

    with open(".config/nvim/.emmyrc.json", "w") as f:
        json.dump(d, f, indent=2)


if "__main__" == __name__:
    main()
