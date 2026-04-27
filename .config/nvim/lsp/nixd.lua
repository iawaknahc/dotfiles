return {
  -- Known issue: inlay hint works only in `with pkgs; [ ... ]`
  -- See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
  cmd = { "nixd", "--inlay-hints=true", "--semantic-tokens=true" },
  settings = {
    nixd = {
      formatting = {
        command = { "nixfmt" },
      },
      nixpkgs = {
        -- This evaluates to the actual pkgs with all overlays applied.
        expr = '(builtins.getFlake (builtins.toString <for-nixd>)).homeConfigurations."nixd@nixd".pkgs',
      },
      -- nixd requires us to provide an expression that will be evaluated the options set.
      -- To do this, we add for-nixd to NIX_PATH, and use a dummy machine nixd@nixd.
      options = {
        ["nix-darwin"] = {
          expr = "(builtins.getFlake (builtins.toString <for-nixd>)).darwinConfigurations.nixd.options",
        },
        ["home-manager"] = {
          expr = '(builtins.getFlake (builtins.toString <for-nixd>)).homeConfigurations."nixd@nixd".options',
        },
      },
    },
  },
}
