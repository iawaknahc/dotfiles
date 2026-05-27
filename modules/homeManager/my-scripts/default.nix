{ pkgs, ... }:
{
  mypython.packages = [
    (
      python-pkgs: with python-pkgs; [
        # timedelta does not support calendrical calculation.
        python-dateutil

        # Timezone handling
        tzdata
        pytz
        tzlocal

        numpy
        scipy
        astropy
        jplephem
      ]
    )
  ];

  home.packages = builtins.map (
    path:
    let
      basename = builtins.baseNameOf (builtins.toString path);
      text = builtins.readFile path;
    in
    (pkgs.writeScriptBin basename text)
  ) (pkgs.lib.fileset.toList (pkgs.lib.fileset.maybeMissing ./bin));
}
