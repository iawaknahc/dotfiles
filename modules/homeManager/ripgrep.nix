{ ... }:
{
  programs.ripgrep.enable = true;
  programs.ripgrep.arguments = [
    # Search hidden files by default.
    "--hidden"
    # Ignore .git
    "--glob=!.git/"

    "--type-add=beancount:*.beancount"
    "--type-add=just:[Jj]ustfile"
    "--type-add=nu:*.nu"
  ];
}
