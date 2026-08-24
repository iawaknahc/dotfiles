from my_rass import common


def servers():
    return [
        ["nixd"],
        ["nil"],
        common.harper(),
        common.typos(),
    ]


def logic_class():
    return common.NixdLogicClass
