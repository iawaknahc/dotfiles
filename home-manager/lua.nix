{
  pkgs,
  ...
}:
let
  lua54 = with pkgs; lua5_4;
in
{
  home.packages = with pkgs; [
    emmylua-ls
    lua-language-server
    stylua

    fennel-ls
    fnlfmt

    # Luarocks hits a limit of LuaJIT.
    # So we have to run luarocks with Lua > 5.1
    # https://github.com/luarocks/luarocks/issues/1797
    (lua54.withPackages (
      packages: with packages; [
        luautf8
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
          # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/by-name/sb/sbarlua/package.nix
          # We know that sbarlua is originally built with lua55Packages.buildLuaPackage
          # So we want to override the package input lua55Packages.
          #
          # With some study, we found out that the lua interpreter packages (such as lua5_4_compat) has an attribute `pkgs`,
          # which is compatible with lua55Packages.
          # See https://nixos.org/manual/nixpkgs/stable/#attributes-on-lua-interpreters-packages
          #
          # So we can simply override lua55Packages with <interpreter-package>.pkgs
          #
          # If we do not override, we will run into a problem of installing 2 conflicting copies of Lua interpreters.
          lua55Packages = lua54.pkgs;
        })
      ]
    ))
  ];
}
