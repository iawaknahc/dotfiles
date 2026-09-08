{
  trivialBuild,
  fetchFromGitHub,
}:
trivialBuild {
  pname = "ecard";
  version = "0-unstable-2026-04-28";
  src = fetchFromGitHub {
    owner = "jwiegley";
    repo = "ecard";
    rev = "e79cd68c49466f132142b5ce1a4eaa4fbb47fb8c";
    hash = "sha256-2c7xlowQBOZqtqtZ/s2BBvKFX33SheTkFYdKoJhBbR8=";
  };
}
