from my_rass import common


def servers():
    return [
        ["pyrefly", "lsp"],
        ["ty", "server"],
        ["ruff", "server"],
        common.codebook(),
        common.harper(),
        common.typos(),
    ]
