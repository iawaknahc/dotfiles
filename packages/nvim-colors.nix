{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "nvim-colors";
  version = "0-unstable-2026-04-21";
  src = fetchFromGitHub {
    owner = "iawaknahc";
    repo = "nvim-colors";
    rev = "5d58b7ff7a53634a10a65c3bdd2f84b9a3447dbf";
    hash = "sha256-9Zm2PJOrJgvjyaVzs7wfnISJ02lky9RSMrlmtlJUSac=";
  };
}
