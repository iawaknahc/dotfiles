{
  buildPythonPackage,
  setuptools,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "py2hy";
  version = "0.3.0";
  pyproject = true;
  build-system = [ setuptools ];
  dontCheckRuntimeDeps = true;
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VZ04oDaKumqUfaN8i0Iqsfn4AhCw2PecUJdwJZcNZjE=";
  };
}
