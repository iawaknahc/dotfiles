from my_rass import common


def servers():
    return [
        ["nixd", "--inlay-hints=true", "--semantic-tokens=true"],
        ["nil"],
        common.harper(),
        common.typos(),
    ]


def logic_class():
    return common.NixdLogicClass
