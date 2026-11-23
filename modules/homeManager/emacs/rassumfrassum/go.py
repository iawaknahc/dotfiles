from my_rass import common


def servers():
    return [
        ["gopls"],
        common.harper(),
        common.typos(),
    ]


def logic_class():
    return common.HarperLogicClass
