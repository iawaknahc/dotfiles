{ ... }:
{
  programs.bat.enable = true;
  programs.bat.config = {
    theme = "Dracula";

    # Make bat works like cat
    style = "plain";
    paging = "never";

    # Assume the underlying terminal supports italic.
    italic-text = "always";
  };
}
