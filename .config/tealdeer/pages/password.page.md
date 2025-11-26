# password

> Personal quick reference on handling password in shell.

- Read a password without echoing and pass it to the `stdin` of another command:

`python3 -c "import getpass; print(getpass.getpass())" | qpdf --password-file=- --decrypt {{input.pdf}} {{output.pdf}}`
