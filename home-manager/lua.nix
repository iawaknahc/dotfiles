{
  pkgs,
  ...
}:
let
  lua = with pkgs; lua5_4;
in
{
  home.packages = with pkgs; [
    lua-language-server
    stylua

    fennel-ls
    fnlfmt

    # Luarocks hits a limit of LuaJIT.
    # So we have to run luarocks with Lua 5.4
    # https://github.com/luarocks/luarocks/issues/1797
    (lua.withPackages (
      packages: with packages; [
        fennel
        luarocks
        # llscheck requires lua-language-server on PATH.
        llscheck
        # luap provides a better REPL experience than lua(1).
        luaprompt
        # JSON
        lua-cjson
        # inspect
        inspect
        # sbarlua is the Lua API to SketchyBar
        (sbarlua.override {
          # By inspecting the source code
          # https://github.com/NixOS/nixpkgs/blob/d8cf13dc00548190c399847ef8acb0640999d748/pkgs/by-name/sb/sbarlua/package.nix#L9
          # We know that sbarlua is originally built with lua54Packages.buildLuaPackage
          # So we want to override the package input lua54Packages.
          #
          # With some study, we found out that the lua interpreter packages (such as lua5_4_compat) has an attribute `pkgs`,
          # which is compatible with lua54Packages.
          # See https://nixos.org/manual/nixpkgs/stable/#attributes-on-lua-interpreters-packages
          #
          # So we can simply override lua54lua54Packages with <interpreter-package>.pkgs
          #
          # If we do not override, we will run into a problem of installing 2 conflicting copies of Lua interpreters.
          lua54Packages = lua.pkgs;
        })
      ]
    ))
  ];
}
