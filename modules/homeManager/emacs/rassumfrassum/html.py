from my_rass import common


def servers():
    return [
        ["vscode-html-language-server", "--stdio"],
        common.harper(),
        common.typos(),
    ]


def logic_class():
    return common.HarperLogicClass
