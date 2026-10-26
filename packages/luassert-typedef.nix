{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "luassert-typedef";
  version = "0-unstable-2023-01-21";
  src = fetchFromGitHub {
    owner = "LuaCATS";
    repo = "luassert";
    rev = "d3528bb679302cbfdedefabb37064515ab95f7b9";
    hash = "sha256-p8ohFmag2WKzDG7avgmw7qr9yA5Q/F2vhXakr3WHZUk=";
  };
  installPhase = ''
    mkdir -p $out/share/luassert-typedef
    cp -r $src/library/. $out/share/luassert-typedef/
  '';
}
