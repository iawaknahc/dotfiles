{
  buildPythonPackage,
  fetchPypi,
  pdm-backend,
  lark,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "autobean_refactor";
  version = "0.3.1";
  pyproject = true;
  build-system = [
    pdm-backend
  ];
  dependencies = [
    lark
    typing-extensions
  ];
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vrvBFrKsYMCCgO6cSJGFLxKhAYW3cyekCqho1CJF6dI=";
  };
}
