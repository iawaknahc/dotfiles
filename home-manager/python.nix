{
  pkgs,
  ...
}:
let
  # python3 is usually one version behind.
  version = "313";
in
{
  nixpkgs.overlays = [
    (final: prev: {
      mypython = prev."python${version}".withPackages (
        python-pkgs: with python-pkgs; [
          tzdata
          pytz
          pyperclip
          tzlocal
          parsy
        ]
      );
    })
  ];

  home.packages = [
    pkgs.mypython
    pkgs.pyright
    pkgs."python${version}Packages".json5
    pkgs."python${version}Packages".debugpy
  ];
}
