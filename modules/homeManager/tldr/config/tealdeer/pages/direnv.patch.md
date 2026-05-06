- List all allowed paths:

`find ~/.local/share/direnv/allow/ -type f -exec sh -c 'printf "$1 -> $(cat $1)\n"' _ {} \;`

- List all denied paths:

`find ~/.local/share/direnv/deny/ -type f -exec sh -c 'printf "$1 -> $(cat $1)\n"' _ {} \;`
