{
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
buildPythonPackage rec {
  pname = "rassumfrassum";
  version = "0.3.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-P7c2j3Pax+8rSsywCSc46rQY+j0hI0Fg5jgzlVD41YI=";
  };

  # Rass is a program written in Python.
  # For some unknown reason, when it runs language servers written for Python, such as, Pyrefly, ty,
  # the absolute path to the interpreter is not the one found in PATH,
  # but the one baked in the wrapped Rass.
  # The one baked in the wrapped Rass is the plain interpreter without any user site-packages.
  # Therefore, when typechecking a Python script that expects user site-packages to have some package installed,
  # Pyrefly and ty will complain the packages are not found.
  #
  # I looked up the documentation of buildPythonPackage[1],
  # there are two possible flags that may work around this issue.
  # The first one is permitUserSite.
  # I tried it and but it does not work.
  # The second one is dontWrapPythonPrograms.
  # I tried it and it worked for me.
  # A weird thing is that when I inspect the binary found in ~/.nix-profile/bin/rass
  # It still looks like it is wrapped though.
  #
  # [1]: https://github.com/NixOS/nixpkgs/blob/26.05/doc/languages-frameworks/python.section.md?plain=1#L172
  dontWrapPythonPrograms = true;
  # permitUserSite = true;

  build-system = [ setuptools ];
  doCheck = false;
}
