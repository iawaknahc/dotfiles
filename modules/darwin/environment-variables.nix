{
  environment.variables = {
    # The default is "nano".
    # https://github.com/LnL7/nix-darwin/blob/master/modules/environment/default.nix#L208
    EDITOR = "vi";
    # The default is "less -R".
    # https://github.com/LnL7/nix-darwin/blob/master/modules/environment/default.nix#L209
    PAGER = "less -R";
  };
}
