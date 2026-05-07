{
  buildPythonPackage,
  setuptools,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "py2hy";
  version = "0.2.1";
  pyproject = true;
  build-system = [ setuptools ];
  dontCheckRuntimeDeps = true;
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6h61S7Glbeg0yPyBCOoSvBt9SXCWgXs58wpEXRvcIKU=";
  };
}
