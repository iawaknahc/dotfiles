# pdf

> Personal quick reference on working with PDF files.

- Convert PostScript to PDF:

`ps2pdf {{input.ps}} {{output.pdf}}`

- Remove the password from a password-protected PDF file:

`python3 -c "import getpass; print(getpass.getpass())" | qpdf --password-file=- --decrypt {{input.pdf}} {{output.pdf}}`
