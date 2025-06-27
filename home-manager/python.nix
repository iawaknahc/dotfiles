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
          # Timezone handling
          tzdata
          pytz
          tzlocal
          # Clipboard
          pyperclip
          # Parse tiny language
          parsy
          # Terminal output
          rich
        ]
      );
    })
  ];

  home.packages = [
    pkgs.mypython
    pkgs.ruff
    pkgs.pyright
    pkgs."python${version}Packages".json5
    pkgs."python${version}Packages".debugpy
  ];
}
