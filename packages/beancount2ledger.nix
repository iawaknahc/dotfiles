{
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  fetchPypi,
  beancount,
  pyyaml,
}:
let
  # beancount2ledger depends on pkg_resources at runtime.
  # This module is provided by setuptools.
  # But it was removed since seutptools 82.
  # So we pinned setuptools to 81.0.0.
  # See https://github.com/pypa/setuptools/issues/5174
  setuptools-lt-82 = setuptools.overridePythonAttrs (_: rec {
    version = "81.0.0";
    src = fetchPypi {
      pname = "setuptools";
      inherit version;
      hash = "sha256-SHtTkV9SUB8Kecz9DALBZf/gZjFEOohnQLka9LelhFo=";
    };
  });
in
buildPythonPackage rec {
  pname = "beancount2ledger";
  version = "1.3";
  pyproject = true;
  build-system = [
    setuptools-lt-82
    setuptools-scm
  ];
  dependencies = [
    beancount
    pyyaml
    setuptools-lt-82
  ];
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-s31BKKVRmKbEZXLkwDY81FlkPPOaBrf22is4eJxcSIA=";
  };
}
