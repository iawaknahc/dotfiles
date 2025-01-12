{ ... }:
{
  programs.fd.enable = true;
  programs.fd.ignores = [
    # Ignore .git even -H is used.
    ".git/"
  ];
}
