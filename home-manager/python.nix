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
        ]
      );
    })
  ];

  home.packages = [
    pkgs.mypython
    pkgs."python${version}Packages".json5
    pkgs."python${version}Packages".debugpy
  ];
}
