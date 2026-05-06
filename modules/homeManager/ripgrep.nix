{ ... }:
{
  programs.ripgrep.enable = true;
  programs.ripgrep.arguments = [
    # Search hidden files by default.
    "--hidden"
    # Ignore .git
    "--glob=!.git/"
  ];
}
