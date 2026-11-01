{
  ...
}:
{
  programs.texlive.enable = true;
  programs.texlive.extraPackages = texlivePackages: {
    inherit (texlivePackages)
      scheme-basic
      # If we do not install this font package,
      # Org mode will leave a log buffer with a warning message saying some font is missing.
      collection-fontsrecommended
      # Org mode requires ulem.
      ulem
      # Org mode has pre-configured preset for dvisvgm.
      dvisvgm
      ;
  };
}
