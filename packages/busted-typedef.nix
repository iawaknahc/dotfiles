{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "busted-typedef";
  version = "0-unstable-2022-11-23";
  src = fetchFromGitHub {
    owner = "LuaCATS";
    repo = "busted";
    rev = "5ed85d0e016a5eb5eca097aa52905eedf1b180f1";
    hash = "sha256-A8YgMXtKnd9nSsRClkfz8cUbKHIUTRN2vudge6EfSgU=";
  };
  installPhase = ''
    mkdir -p $out/share/busted-typedef
    cp -r $src/library/. $out/share/busted-typedef/
  '';
}
