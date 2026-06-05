{
  buildPythonPackage,
  fetchPypi,
  pdm-backend,
  autobean_refactor,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "autobean_format";
  version = "0.1.8";
  pyproject = true;
  build-system = [
    pdm-backend
  ];
  dependencies = [
    autobean_refactor
    typing-extensions
  ];
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aZzwVUV7cGZrHWSLYM7Obdrhe8x0mS7Vld8Z7rtJzcc=";
  };
}
