{
  buildPythonPackage,
  rustPlatform,
  maturin,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "pyxirr";
  version = "0.10.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pWIN12AVRE8m+AXEmDpBZkiY+/KnSVaihYmxce2W0vU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname src version;
    hash = "sha256-YCpCkq00q9LXiihn+73Q4QlGbPGmMdTurwuABiFkj6Q=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  build-system = [ maturin ];
}
