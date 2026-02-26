{ ... }:
{
  programs.fzf.enable = true;
  programs.fzf.defaultCommand = ''
    fd --type f
  '';
  programs.fzf.defaultOptions = [
    # Setting --with-shell breaks the CTRL-R key binding introduced by
    # https://github.com/junegunn/fzf/blob/master/shell/key-bindings.fish
    # "--with-shell='sh -c'"
    "--height=40%"
    "--layout=reverse"
    "--border"
  ];
}
