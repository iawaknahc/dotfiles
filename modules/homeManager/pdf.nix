{ pkgs, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        pdfminer-six # https://github.com/pdfminer/pdfminer.six
        pdfplumber # https://github.com/jsvine/pdfplumber
        pymupdf # https://github.com/pymupdf/pymupdf
        pypdf # https://github.com/py-pdf/pypdf
        camelot # https://github.com/camelot-dev/camelot
      ]
    )
  ];

  home.packages = with pkgs; [
    qpdf
    poppler-utils
    ghostscript
  ];
}
