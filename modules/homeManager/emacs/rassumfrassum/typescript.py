from my_rass import common


def servers():
    return [
        ["tsgo", "--lsp", "--stdio"],
        common.codebook(),
        common.harper(),
        common.typos(),
    ]


def logic_class():
    return common.HarperLogicClass
