from my_rass import common


def servers():
    return [
        ["beancount-language-server", "--stdio"],
        common.typos(),
    ]
